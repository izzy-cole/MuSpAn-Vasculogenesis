# MuSpAn-Vasculogenesis

Tool to perform persistent homology analysis (a Topological Data Analysis technique) on blood island images in chicken embryos. Uses MuSpAn ([Multiscale Spatial Analysis Toolbox](https://www.muspan.co.uk)) to run persistent homology with level-set filtration (filtration from bright to dark pixel values).

**Installation and use**

Request a licence for MuSpAn (Academic Use Licence) and install.
```bash

git clone git@github.com:izzy-cole/MuSpAn-Vasculogenesis.git

cd MuSpAn-Vasculogenesis


pip install -r requirements.txt

```

Run the image preprocessing script *PH_histograms.ijm* via Fiji/ImageJ to standardise shading histograms.

Run the image preprocessing script *PH_all.ijm* via Fiji/ImageJ to filter out small, noisy particles.

Run *muspan\_PH\_filtering.ipynb* to perform and analyse persistent homology results on your dataset.



