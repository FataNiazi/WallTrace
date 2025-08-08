import numpy as np
import math
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score


def random_forest(X_train, X_val, Y_train, Y_val, criterion, max_depth, n_estimators):
    clf = trained_random_forest(X_train, Y_train, criterion, max_depth, n_estimators)
    Y_pred = clf.predict(X_val)
    accuracy = accuracy_score(Y_val, Y_pred)
    print(
        f"Criterion: {criterion}\tTrees: {n_estimators}\tMax Depth: {max_depth}\tAccuracy: {accuracy:.4f}"
    )
    return accuracy


def trained_random_forest(X_train, Y_train, criterion, max_depth, n_estimators):
    clf = RandomForestClassifier(
        criterion=criterion,
        max_depth=max_depth,
        n_estimators=n_estimators,
        random_state=1,
        n_jobs=-1,
    )
    clf.fit(X_train, Y_train)
    return clf


def entropy(counts):
    total = np.sum(counts)
    if total == 0:
        return 0
    probabilities = counts / total
    entropy = 0
    for p in probabilities:
        if p > 0:  # Avoid log(0)
            entropy += p * math.log2(p)
    return -entropy


def compute_information_gain(tree, node):
    N = tree.n_node_samples[node]

    # left
    left = tree.children_left[node]
    N_left = (
        tree.n_node_samples[left] if left != -1 else 0
    )  # make sure this isnt a leaf

    # right
    right = tree.children_right[node]
    N_right = (
        tree.n_node_samples[right] if right != -1 else 0
    )  # make sure this isnt a leaf

    # entropy of parent
    entropy_parent = entropy(tree.value[node][0])
    # weighted average entropy of children
    entropy_children = ((N_left / N) * (entropy(tree.value[left][0]))) + (
        (N_right / N) * (entropy(tree.value[right][0]))
    )

    return entropy_parent - entropy_children
