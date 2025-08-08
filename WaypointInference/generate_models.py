from data.data import load_data
from sklearn.model_selection import train_test_split
from knn import trained_knn_model
from decision_forest import trained_random_forest
import joblib

X, Y = load_data("data/waypoints.json")
X_train, X_val, Y_train, Y_val = train_test_split(X, Y, test_size=0.2, random_state=42)
Knn = trained_knn_model(1, X_train, Y_train)
random_forest = trained_random_forest(X_train, Y_train, "gini", 20, 20)

joblib.dump(Knn, "models/knn_model.joblib")
joblib.dump(random_forest, "models/random_forest.joblib")
