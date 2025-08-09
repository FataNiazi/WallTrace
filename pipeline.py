from RoomIdentifier.trainRoomClassifier import RoomClassifier, predict
from WaypointInference.tokenizer import get_embeddings
from WaypointInference.inference import (
    knn_multiple_strings,
    random_forest_multiple_strings,
)
import torch
import joblib
import time


### Make sure to generate the models before running
### cd RoomIdentifier, run trainRoomClassifier.py then cd WaypointInference, run generate_models.py


ROOM_CLASSIFIER_PATH = "RoomIdentifier/room_classifier.pt"
KNN_PATH = "WaypointInference/models/knn_model.joblib"
RANDOM_FOREST_PATH = "WaypointInference/models/random_forest.joblib"

device = torch.device("cuda")


def load_models():
    room_classifier = RoomClassifier().to(device)
    room_classifier.load_state_dict(
        torch.load(ROOM_CLASSIFIER_PATH, map_location=device)
    )
    room_classifier.eval()
    knn = joblib.load(KNN_PATH)
    random_forest = joblib.load(RANDOM_FOREST_PATH)
    return room_classifier, knn, random_forest


def run_pipeline(sentences: list[str], model="knn"):
    room_classifier, knn, random_forest = load_models()

    valid_sentences = []

    start = time.time()
    ### MODEL 1 ###
    embedding_time = 0
    for sentence in sentences:
        # Run Abhi's room classifier on each word
        pred, _, pred_time = predict(sentence, room_classifier)
        embedding_time += pred_time
        if pred == 1:
            valid_sentences.append(sentence)
    end = time.time()
    print(
        f"Model1 embedding took {embedding_time} seconds for {len(sentences)} inputs."
    )
    print(
        f"Model1 classification took {end - start} seconds for {len(sentences)} inputs."
    )

    start = time.time()
    embeddings = get_embeddings(valid_sentences)
    end = time.time()
    print(
        f"Model2 embedding took {end - start} seconds for {len(valid_sentences)} inputs."
    )

    ### MODEL 2 ###
    if model == "knn":
        start = time.time()
        pred = knn_multiple_strings(knn, embeddings)
        end = time.time()
    elif model == "random_forest":
        start = time.time()
        pred = random_forest_multiple_strings(random_forest, embeddings)
        end = time.time()
    else:
        raise NameError(
            "Selected model not valid. Supported models are: knn, random_forest"
        )
    print(
        f"Model2 classification ({model}) took {end - start} seconds for {len(valid_sentences)} inputs."
    )
    print("Predicted waypoint:", int(pred))


if __name__ == "__main__":
    strings = [
        "ELECTRICAL ROOM",
        "8259",
        "Ra 8259",
        "65281",
        "ELECTRICAL ROO",
        "ECECTRICAN",
        "8258",
    ]
    run_pipeline(strings, model="knn")
