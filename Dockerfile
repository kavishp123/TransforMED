# Start with a base image with Python 3.8 or newer
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /app

# Install system dependencies required for the Python environment and GPU support
RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install CUDA dependencies for GPU support (if needed, uncomment below lines)
# RUN apt-get update && apt-get install -y \
#    nvidia-cuda-toolkit nvidia-driver

# Install dependencies for the script (includes PyTorch, HuggingFace Transformers, etc.)
RUN pip install --upgrade pip

# Install necessary Python packages
RUN pip install torch==1.10.0 \
    transformers==4.12.0 \
    datasets==2.0.0 \
    scikit-learn \
    tqdm \
    pandas

# Clone your repo or copy your files into the container (adjust paths as needed)
# COPY . /app

# If you're pulling from a remote repo, you can do this instead:
# RUN git clone <your-repository-url>

# Set environment variables (adjust paths as needed)
ENV DATA_DIR=/app/data/neoplasm/
ENV TASK_NAME=seqtag
ENV MODELTYPE=bert-seqtag
ENV MAXSEQLENGTH=128
ENV OUTPUTDIR=/app/output/$TASK_NAME+$MAXSEQLENGTH/
ENV MODEL=monologg/scibert_scivocab_uncased

# Expose port (if required)
EXPOSE 8000

# Run the Python training script
CMD ["python", "train.py", \
    "--model_type", "$MODELTYPE", \
    "--model_name_or_path", "$MODEL", \
    "--output_dir", "$OUTPUTDIR", \
    "--task_name", "$TASK_NAME", \
    "--do_train", \
    "--do_eval", \
    "--do_lower_case", \
    "--data_dir", "$DATA_DIR", \
    "--max_seq_length", "$MAXSEQLENGTH", \
    "--overwrite_output_dir", \
    "--per_gpu_train_batch_size", "32", \
    "--learning_rate", "2e-5", \
    "--num_train_epochs", "3.0", \
    "--save_steps", "1000", \
    "--overwrite_cache"]
