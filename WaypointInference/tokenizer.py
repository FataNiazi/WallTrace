from transformers import AutoTokenizer, AutoModel
import torch
import torch.nn.functional as F

tokenizer = AutoTokenizer.from_pretrained("sentence-transformers/all-MiniLM-L6-v2")
model = AutoModel.from_pretrained("sentence-transformers/all-MiniLM-L6-v2")


# Mean Pooling - Take attention mask into account for correct averaging
def mean_pooling(model_output, attention_mask):
    token_embeddings = model_output[
        0
    ]  # First element of model_output contains all token embeddings
    input_mask_expanded = (
        attention_mask.unsqueeze(-1).expand(token_embeddings.size()).float()
    )
    return torch.sum(token_embeddings * input_mask_expanded, 1) / torch.clamp(
        input_mask_expanded.sum(1), min=1e-9
    )


def get_embeddings(sentences: list[str]):
    encoded_input = tokenizer(
        sentences, padding=True, truncation=True, return_tensors="pt"
    )

    # Compute token embeddings
    with torch.no_grad():
        model_output = model(**encoded_input)
    # Perform pooling
    sentence_embeddings = mean_pooling(model_output, encoded_input["attention_mask"])
    # Normalize embeddings
    sentence_embeddings = F.normalize(sentence_embeddings, p=2, dim=1)

    # print("Sentence embeddings:")
    # print(sentence_embeddings)
    return sentence_embeddings


### Conversion to ONNX, for running on the iPhone
dummy_input = tokenizer(
    ["This is a test sentence"], return_tensors="pt", padding=True, truncation=True
)


def convert_to_onnx():
    # Export the model
    return torch.onnx.export(
        model,
        (dummy_input["input_ids"], dummy_input["attention_mask"]),
        "all_MiniLM_L6_v2.onnx",
        input_names=["input_ids", "attention_mask"],
        output_names=["output"],
        dynamic_axes={
            "input_ids": {0: "batch_size", 1: "sequence"},
            "attention_mask": {0: "batch_size", 1: "sequence"},
        },
        opset_version=11,
    )


if __name__ == "__main__":
    from data.data import load_data

    data = load_data("data/waypoints.json")
    get_embeddings(data[0]["texts"])
