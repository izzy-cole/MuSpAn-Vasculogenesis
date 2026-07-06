//will skip existing files in the Python folder
//combination script that takes an image, breaks it up into 255 threshold values, removes small particles, then puts the image back together
setBatchMode(true);

drug_name = "mmp brendan2";
conditions = newArray("Control","10um", "20um","30um");

drug_name = "mmp brendan";
conditions = newArray("10um", "30um","50um");

//drug_name = "mmp hh8+24hr";
//conditions = newArray("control","10um", "20um");

min_particle_size = 10;
crop = false;

stack_size=256;


for (s=0;s<conditions.length;s++){
	stage = conditions[s];

	//PART 1: creates an image stack where each image is a different threshold level
	main_path = "C:/Users/isabe/Documents/work/systems bio/modelling vasculogenesis/hh_stages_fixed_images/drug_perturbation_set/"+drug_name+"/PH/";
	python_path = "C:/Users/isabe/Documents/work/systems bio/modelling vasculogenesis/python/data/PH_drugs/"+drug_name+"/"+min_particle_size+"um/";
	original_file_name =  conditions[s]+"_hist";
	base_name = conditions[s];
	
	//Check if file exists (eg n<5 sometimes)
	if (!File.exists(main_path+original_file_name+".tif")) {
		print("File does not exist, skipping");
		continue;
	} else{
		print("File found");
	}
	
	// --- ALREADY PROCESSED CHECK ---
    // This reconstructs the final name saved at the end of Part 3
    final_output = python_path + base_name + "_cleaned_" + min_particle_size + "um.png";
    if (File.exists(final_output)) {
        print("Skipping: " + original_file_name + " (Already processed)");
        continue; // Jump to the next embryo
    }
	
	open(main_path+original_file_name+".tif");
	imgID=getImageID();

	
	// --- CALIBRATION SAFETY CHECK ---
    getPixelSize(unit, pixelWidth, pixelHeight);
    if (unit == "pixels" || unit == "pixel" || unit == "") {
        print("WARNING: No micron calibration found for " + original_file_name + ".tif");
        close();
        continue; // Skip to the next embryo
    }
	
	
	getDimensions(width, height, channels, slices, frames);
	max_width = 700;
	scale_ratio = max_width/width;
	run("Scale...", "x="+scale_ratio+" y="+scale_ratio+" interpolation=Bilinear average create");

	
	
	// --- MANUAL CROP STEP ---
	if (crop){
        setBatchMode("show"); // Temporarily show the image so you can see it
        setTool("rectangle"); // Automatically select the rectangle tool for you
        
        // This pauses the macro until you click "OK" on the popup window
        waitForUser("Manual Crop", "Draw a rectangle closely around the embryo to remove black space.\nIf no crop is needed, just click OK.\nImage: " + original_file_name);
        
        // Check if you actually drew a box. If yes (selection != -1), crop it.
        if (selectionType() != -1) {
            run("Crop");
            run("Select None"); // clear the yellow box line
        }
        
        setBatchMode("hide"); // Hide the image again to resume fast background processing
        // ------------------------
	}
	
	run("8-bit");
	run("Apply LUT");
	run("Gaussian Blur...", "sigma=10 scaled");
	rename("working");
	
	getDimensions(width, height, channels, slices, frames);
	newImage("threshold_stack", "8-bit black", width, height, stack_size);
	stackID=getImageID();
	
	for (i=0; i<=stack_size-1; i++) {
	    // Threshold on original image
	    selectImage("working");
	    run("Duplicate...","title=temp_slice");
	    setThreshold(i, 255, "raw");
	    
	    run("Convert to Mask"); //apply threshold
	    run("Copy");
	    
	    selectImage(stackID);
	    setSlice(i + 1); // Slice indices are 1-based (Slice 1 = Threshold 0)
	    run("Paste"); //paste onto stack
	    
	    close("temp_slice");
	    
	}

	//PART 2: removes particles smaller than 500 suqare microns
	
	selectImage(stackID);
	
	run("Duplicate...", "title=duplicate_stack duplicate");
	run("Analyze Particles...", "size="+min_particle_size+"-Infinity show=Masks stack");
	rename("mask1");
	
	
	selectImage("mask1");
	run("Invert LUT");
	run("Invert", "stack");
	
	run("Analyze Particles...", "size="+min_particle_size+"-Infinity show=Masks stack");
	rename("mask2");
	
	selectImage("mask2");
	run("Invert", "stack");
	run("Invert LUT");
	
	rename("cleaned_stack");

	//PART 3: reconstruct a 255-threshold stack back into an image
	
	
	selectImage("cleaned_stack");

	getDimensions(width, height, channels, slices, frames);
	
	newImage("reconstructed", "8-bit black", width, height, 1);
	
	
	for (i=1; i<=stack_size; i++) {
		selectImage("cleaned_stack");
		run("Duplicate...", "title=add_layer duplicate range="+i);
		run("Divide...", "value=255");
	
		imageCalculator("Add", "reconstructed","add_layer");
	
		close("add_layer");
	}
	
	selectImage("reconstructed");
	run("Copy");
	

	saveAs("Tiff", main_path + base_name + "_Cleaned_" + min_particle_size + "um.tif");
	
	getDimensions(width, height, channels, slices, frames);
	newImage("border", "8-bit black", width+2, height+2, 1);
	run("Paste");

	saveAs("png", python_path + base_name + "_Cleaned_" + min_particle_size + "um.png");
	print("Finished file "+ stage);
	close("*");
		
}