Implementation details:

HOG Descriptor:
1. The HOG is implemented in 2 parts.
2. The first one titled ‘hogVisual.m’ implements HOG to images for which a visualization of the
descriptor is required. This script internally calls the function ‘findHistBlockVisu()’ which
essentially computes the HOG for a 16x16 block and also returns its visualization.
3. The second part implements HOG in such a way that it read a renamed version of the INRIA
dataset’s positive and negative examples, stores the descriptor of each of the images in an array
and saves a .mat file.
Note: The second part may not execute without the modified INRIA dataset present in the
current matlab folder. The modified dataset is not included in the submission due to size
constraints.

SVM Training
1. The entire SVM Training has been implemented in the script ‘SVMTrain.m’.
2. The script requires the descriptor .mat files, which were saved in Part A of the assignment, in
the current folder of Matlab. This can be downloaded from:
https://www.dropbox.com/s/kgrd805cusqc7mp/Descriptors.zip?dl=0
3. Extract the zip folder contents to the current matlab folder and run the script ‘SVMTrain.m’
4. Output of the quadprog is saved in the variable ‘Wb’

HOG-SVM Detection
1. The entire implementation is in the file ‘detectPedestriansHOG.m’.
2. To run the script, the trained data is needed from SVM. This was generated from the previous
script, which was submitted in Part B. This has to be in the directory ‘Results/Wb.mat’. The
entire directory containing the file ‘Wb.mat’ is attached with the submission.
3. The script reads the input image, generates a scale space and using a sliding window approach
calculates the HOG descriptors using the function ‘findHistBlock()’.
4. The SVM weights are then multiplied and added with the bias, to obtain the scores of the all
window positions in the image over all the entire scale space.
5. All the positive scores undergo non maxima suppression and bounding box overlap analysis to
individually detect all pedestrians (humans) in the input images.
6. Output is shown as a figure with a bounding box around each detected pedestrian/human.
Note: For all the images shown, a step size of 10 has been used for the sliding window, an overlap ratio
of 0.9 is employed.
