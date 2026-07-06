stages = newArray(3,4,5,6,7,8,9,10,11,12,13);

//drug_name = "mmp brendan2";
//conditions = newArray("Control", "10uM", "30uM","50uM");

drug_name = "mmp hh8+24hr";
conditions = newArray("control","10um", "20um");

//drug_name = "mmp brendan";
//conditions = newArray("10um", "30um","50um");

base_path = "C:/Users/isabe/Documents/work/systems bio/modelling vasculogenesis/hh_stages_fixed_images/drug_perturbation_set/"+drug_name+"/";

for (i=0;i<conditions.length;i++){
	stage = conditions[i];
		
		phFolder = base_path + "PH/";
    	skelFolder = base_path + "skeleton/";
   

    	phPath = phFolder+stage+ " BC.tif";
    	skelPath = skelFolder+stage+ " BC.tif";
    	
    	if (File.exists(phPath)) {
        	print("Embryo " + stage + ": Found in PH folder. Opening...");
        	open(phPath);
        
    	// 2. If not, check if it exists in the skeleton folder
    	} else if (File.exists(skelPath)) {
        	print("Embryo " + stage + ": Not in PH. Opening from skeleton folder...");
        	open(skelPath);
            	
    	} else {
        	print("Embryo " + stage + ": File not found in either folder. Skipping.");
        	continue; 
    	}
    	
    	saveAs("Tiff", phPath);
    	
    	getStatistics(area, mean, min, max, std, histogram);
    	
    	setMinAndMax(0, max);
    	
    	setTool("rectangle");
        waitForUser("Background Selection", "Embryo " + stage + ": Draw a rectangle over the 'black' background area, then click OK.");
        
        if (selectionType() == -1) {
            exit("No selection was made. Macro aborted.");
        }
        
        // Get background mean
        getStatistics(boxArea, boxMean);
        blackValue = boxMean;
        
         // Clear selection to measure whole image
        run("Select None");
        
        // Create a temporary duplicate to find a noise-free maximum
        run("Duplicate...", "title=temp_blur");
        run("Median...", "radius=10"); // Blurs out noise and hot pixels
        getStatistics(fullArea, fullMean, fullMin, robustMax);
        close(); // Close the temporary blurred image
        
        
        // Set the display range
        setMinAndMax(blackValue, robustMax);
        
        // 4. Save the final updated image into the PH folder
        // (Because we used saveAs above, the active image is already mapped to the PH path)
        run("Save");
        print("Embryo " + stage + ": Histogram updated and saved to PH.");
        
		saveAs("Tiff", phFolder+stage+"_hist.tif");
    

    	close();
       	
	
}