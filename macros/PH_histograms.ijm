stages = newArray(3,4,5,6,7,8,9,10,11,12,13);
base_path = "C:/Users/isabe/Documents/work/systems bio/modelling vasculogenesis/hh_stages_fixed_images/";
save_path = "C:/Users/isabe/Documents/work/systems bio/modelling vasculogenesis/python/data/PH_histograms/";
n_s = newArray("1", "2", "3", "4", "5");

for (i=0;i<stages.length;i++){
	stage = stages[i];
	for (n = 0; n <= n_s.length; n++) {
		
		phFolder = base_path + "hh"+stage + "/" + n + "/PH/";
    	skelFolder = base_path + "hh"+stage + "/" + n + "/skeleton/";
   
   
   		if (!File.exists(phFolder)) {
        	File.makeDirectory(phFolder);
    	}
    
    	phPath = phFolder + "n"+n+"_hh"+stage+"_BC.tif";
    	skelPath = skelFolder + "hh"+stage+"BC.tif";
    	
    	if (File.exists(phPath)) {
        	print("Embryo " + n + ": Found in PH folder. Opening...");
        	open(phPath);
        
    	// 2. If not, check if it exists in the skeleton folder
    	} else if (File.exists(skelPath)) {
        	print("Embryo " + n + ": Not in PH. Opening from skeleton folder...");
        	open(skelPath);
            	
    	} else {
        	print("Embryo " + n + ": File not found in either folder. Skipping.");
        	continue; 
    	}
    	
    	saveAs("Tiff", phPath);
    	
    	getStatistics(area, mean, min, max, std, histogram);
    	
    	setMinAndMax(0, max);
    	
    	setTool("rectangle");
        waitForUser("Background Selection", "Embryo " + n + ": Draw a rectangle over the 'black' background area, then click OK.");
        
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
        // (Because used saveAs above, the active image is already mapped to the PH path)
        run("Save");
        print("Embryo " + n + ": Histogram updated and saved to PH.");
        
		saveAs("Tiff", save_path+"n"+n+"_hh"+stage+"_plain_scaled.tif");
		
		run("Apply LUT");
        saveAs("png", save_path+"n"+n+"_hh"+stage+"_PH_hist.png");
    

    	close();
        	
	}
}