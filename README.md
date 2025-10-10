# Using a robust data pipelining tool in R to build a reproducible hurricane data visualization with multi-agency water data

## How to run

## Running on Binder
The notebook is designed to be launched from Binder. 

Click the **Launch Binder** button at the top level of the repository

## Running locally
You may also download the notebook from GitHub to run it locally:
1. Open your terminal

2. Check your conda install with `conda --version`. If you don't have conda, install it by following these instructions (see [here](https://docs.conda.io/en/latest/miniconda.html))

3. Clone the repository
    ```bash
    git clone https://github.com/eds-book/2dd74dfa-d87d-442f-bea1-a19c8953f66e.git
    ```

4. Move into the cloned repository
    ```bash
    cd 2dd74dfa-d87d-442f-bea1-a19c8953f66e
    ```

5. Create and activate your environment from the `environment.yml` file
    ```bash
    conda env create -f .binder/environment.yml
    conda activate 2dd74dfa-d87d-442f-bea1-a19c8953f66e
    R --quiet -f .binder/install.R
    ```  

6. Launch the jupyter interface of your preference, notebook, `jupyter notebook` or lab `jupyter lab`