from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier
from sklearn.ensemble import RandomForestClassifier
import numpy as np


def most_common(preds):
    values, counts = np.unique(preds, return_counts=True)
    most_frequent = values[np.argmax(counts)]
    return most_frequent


def knn_multiple_strings(Knn: KNeighborsClassifier, string_embeddings):
    preds = Knn.predict(string_embeddings)
    return most_common(preds)


def random_forest_multiple_strings(
    random_forest: RandomForestClassifier, string_embeddings
):
    preds = random_forest.predict(string_embeddings)
    return most_common(preds)


if __name__ == "__main__":
    from data.data import load_data
    from knn import trained_knn_model
    from tokenizer import get_embeddings

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

    pred = knn_multiple_strings(Knn, strings)
    print("Prediction: ", pred)
