# WallTrace

To run the code in this repo, initialize a virtual environment and install the pip dependencies outlined in requirements.txt. 
NOTE: We used Python 3.12.3 for this project. 

Then, you will need to train the models locally. The code assumes that you have a Nvidia GPU with CUDA support.

1. cd into RoomIdentifier
2. run trainRoomClassifier.py. This will train and save Model1. 
3. cd into WaypointInference
4. run generate_models.py. This will train and save the two diffrent versions of Model2 (knn, random_forest). 
5. cd into the root directory. You can now run pipeline.py, which demonstrates how our pipeline takes text cues from OCR
and processes them through the pipeline. 
6. To compute training statistics for Model2 and visualize with matplotlib, cd into WaypointInference and run main.py. 
