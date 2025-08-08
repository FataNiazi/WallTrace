from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score


def k_nearest(k, X_train, X_val, Y_train, Y_val):
    knn = KNeighborsClassifier(n_neighbors=k)
    knn.fit(X_train, Y_train)

    Y_pred_train = knn.predict(X_train)
    Y_pred_val = knn.predict(X_val)
    train_acc = accuracy_score(Y_train, Y_pred_train)
    val_acc = accuracy_score(Y_val, Y_pred_val)

    print(f"K: {k} \tAccuracy: {val_acc:.4f}")
    return train_acc, val_acc


def trained_knn_model(k, X_train, Y_train):
    knn = KNeighborsClassifier(n_neighbors=k)
    knn.fit(X_train, Y_train)
    return knn
