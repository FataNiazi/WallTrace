import numpy as np
from tokenizer import get_embeddings
import json

M = 384


def load_data(path: str):
    with open(path) as data:
        data = json.load(data)
        X = np.empty((0, M))
        Y = np.empty((0, 1))

        for waypoint in data:
            embeddings = get_embeddings(waypoint["texts"])
            new_labels = np.full((embeddings.shape[0], 1), waypoint["id"])
            X = np.vstack((X, embeddings))
            Y = np.vstack((Y, new_labels))

        return X, Y.ravel()
