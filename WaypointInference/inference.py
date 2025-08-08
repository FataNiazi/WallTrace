from data.data import load_data
from sklearn.model_selection import train_test_split
from knn import trained_knn_model
from sklearn.neighbors import KNeighborsClassifier
from tokenizer import get_embeddings
import numpy as np


def inference_multiple_strings(Knn: KNeighborsClassifier, strings):
    preds = Knn.predict(strings)
    values, counts = np.unique(preds, return_counts=True)
    most_frequent = values[np.argmax(counts)]
    return most_frequent


if __name__ == "__main__":
    X, Y = load_data("data/waypoints.json")
    X_train, X_val, Y_train, Y_val = train_test_split(
        X, Y, test_size=0.2, random_state=42
    )
    Knn = trained_knn_model(1, X_train, Y_train)

    # Some random data I picked from the json
    strings = [
        "ELECTRICAL ROOM",
        "8259",
        "Ra 8259",
        "65281",
        "ELECTRICAL ROO",
        "ECECTRICAN",
        "8258",
    ]
    strings = get_embeddings(strings)
    print(strings.shape)

    pred = inference_multiple_strings(Knn, strings)
    print("Prediction: ", pred)
