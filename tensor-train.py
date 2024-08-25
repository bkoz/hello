import os
import tempfile
import tensorflow as tf

import ray
from ray import train
from ray.train import Checkpoint, ScalingConfig
from ray.train.tensorflow import TensorflowTrainer

def build_model():
    # toy neural network : 1-layer
    return tf.keras.Sequential(
        [tf.keras.layers.Dense(
            1, activation="linear", input_shape=(1,))]
    )

def train_loop_per_worker(config):
    dataset_shard = train.get_dataset_shard("train")
    strategy = tf.distribute.experimental.MultiWorkerMirroredStrategy()
    with strategy.scope():
        model = build_model()
        model.compile(
            optimizer="Adam", loss="mean_squared_error", metrics=["mse"])

    tf_dataset = dataset_shard.to_tf(
        feature_columns="x",
        label_columns="y",
        batch_size=1
    )
    for epoch in range(config["num_epochs"]):
        model.fit(tf_dataset)

        # Create checkpoint.
        checkpoint_dir = tempfile.mkdtemp()
        model.save_weights(
            os.path.join(checkpoint_dir, "my_checkpoint")
        )
        checkpoint = Checkpoint.from_directory(checkpoint_dir)

        train.report(
            {},
            checkpoint=checkpoint,
        )

train_dataset = ray.data.from_items([{"x": x, "y": x + 1} for x in range(32)])
trainer = TensorflowTrainer(
    train_loop_per_worker=train_loop_per_worker,
    scaling_config=ScalingConfig(num_workers=3, use_gpu=True),
    datasets={"train": train_dataset},
    train_loop_config={"num_epochs": 2},
)
result = trainer.fit()
