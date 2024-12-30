# Digit Recognition using CNN in R

## Overview
This project implements a Convolutional Neural Network (CNN) for digit recognition using the R programming language. The model is trained to classify handwritten digits, achieving an accuracy of **85%**. The project is executed in **R Studio** and demonstrates the use of deep learning techniques for image classification.

## Features
- **Convolutional Neural Network (CNN)**: A deep learning architecture optimized for image recognition tasks.
- **Handwritten Digit Classification**: Predicts digits from 0 to 9.
- **Executed in R Studio**: Fully implemented in R, leveraging popular deep learning libraries.
- **85% Accuracy**: A solid performance demonstrating the effectiveness of CNNs.

## Prerequisites
Before you begin, ensure you have the following:
- R (version 4.0 or later)
- R Studio
- Required R libraries:
  - `keras`
  - `tensorflow`
  - `ggplot2`
  - `dplyr`

## Installation
1. Install R and R Studio if not already installed.  
   [Download R](https://cran.r-project.org/)  
   [Download R Studio](https://www.rstudio.com/)

2. Install the required libraries:
   ```R
   install.packages(c("keras", "tensorflow", "ggplot2", "dplyr"))
   library(keras)
   library(tensorflow)
   ```

3. Set up TensorFlow:
   ```R
   install_keras()
   ```

## Dataset
The project uses the MNIST dataset for training and testing. This dataset is included in the `keras` library and can be loaded directly.

## Usage
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/digit-recognition-cnn.git
   cd digit-recognition-cnn
   ```

2. **Open R Studio**:
   - Open the `digit_recognition.R` script in R Studio.

3. **Run the Script**:
   - Execute the script step-by-step or run the entire script to train and evaluate the CNN model.

4. **Model Training**:
   - The model trains on the MNIST dataset and evaluates accuracy on the test set.

5. **Predictions**:
   - Test the model with your own digit images (converted to the required format).

## Directory Structure
```
digit-recognition-cnn/
├── app.R                    # Main script for training and evaluation
├── train.csv                # Placeholder for  dataset
├── README.md                # Project documentation
```

## Results
- **Training Accuracy**: 85%
- **Validation Accuracy**: 85%
- The model demonstrates strong performance in recognizing handwritten digits.

## Future Work
- Experiment with deeper CNN architectures to improve accuracy.
- Implement data augmentation to increase dataset variability.
- Develop a graphical user interface (GUI) for easy digit recognition.

## Contributing
Contributions are welcome! If you have suggestions or improvements, feel free to open an issue or submit a pull request.


