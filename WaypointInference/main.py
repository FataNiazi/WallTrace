from data.data import load_data
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from data.data import load_data

from knn import k_nearest
from decision_forest import random_forest


def test_knn():
    """
    Trains KNeighborsClassifier using different values of k.
    Evaluates performance on the validation set.
    """
    X, Y = load_data("data/waypoints.json")
    X_train, X_val, Y_train, Y_val = train_test_split(
        X, Y, test_size=0.2, random_state=42
    )

    k_values = list(range(1, 21))
    train_accuracies = []
    val_accuracies = []

    for k in k_values:
        train_acc, val_acc = k_nearest(k, X_train, X_val, Y_train, Y_val)
        train_accuracies.append(train_acc)
        val_accuracies.append(val_acc)

    # Plotting
    plt.figure(figsize=(10, 6))
    plt.plot(k_values, train_accuracies, label="Training Accuracy", marker="o")
    plt.plot(k_values, val_accuracies, label="Validation Accuracy", marker="s")
    plt.xlabel("Number of Neighbors (k)")
    plt.ylabel("Accuracy")
    plt.title("KNN Accuracy vs. k")
    plt.xticks(k_values)  # Set x-axis to show only integer values of k
    plt.legend()
    plt.tight_layout()
    plt.show()


def test_random_forests():
    """
    Trains RandomForestClassifier using different values of max_depth and n_estimators.
    Evaluates performance on the validation set.
    """
    max_depths = [2, 4, 8, 16, 32, 64]
    n_estimators_list = [10, 20, 40, 80, 160]
    criterion_list = ["gini", "entropy"]  # RandomForest does NOT support 'log_loss'

    X, Y = load_data("data/waypoints.json")

    X_train, X_val, Y_train, Y_val = train_test_split(
        X, Y, test_size=0.2, random_state=42
    )
    results = {}

    for criterion in criterion_list:
        for n_estimators in n_estimators_list:
            accuracies = []
            for max_depth in max_depths:
                accuracy = random_forest(
                    X_train, X_val, Y_train, Y_val, criterion, max_depth, n_estimators
                )
                accuracies.append(accuracy)
            results[(criterion, n_estimators)] = accuracies

    # Plotting
    for key in results:
        label = f"{key[0]} | # trees={key[1]}"
        plt.plot(max_depths, results[key], label=label)

    plt.xlabel("Max Depth")
    plt.ylabel("Validation Accuracy")
    plt.title("Random Forest Validation Accuracy")
    plt.legend()
    plt.grid(True)
    plt.show()


if __name__ == "__main__":
    test_knn()
    test_random_forests()
