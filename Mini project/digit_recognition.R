# Load necessary libraries
library(caret)
library(nnet)
library(mxnet)
library(imager)

# Load and preprocess the data
data <- read.csv("train.csv")

dim(data)
head(data[1:6])
unique(unlist(data[1]))
min(data[2:785])
max(data[2:785])

# Look at two samples, the 4th and 7th image
sample_4 <- matrix(as.numeric(data[4,-1]), nrow = 28, byrow = TRUE)
image(sample_4, col = grey.colors(255))

sample_7 <- matrix(as.numeric(data[7,-1]), nrow = 28, byrow = TRUE)
image(sample_7, col = grey.colors(255))

# Rotate the matrix by reversing elements in each column
rotate <- function(x) t(apply(x, 2, rev)) 

# Look at the rotated images
image(rotate(sample_4), col = grey.colors(255))
image(rotate(sample_7), col = grey.colors(255))

# Transform target variable "label" from integer to factor, in order to perform classification
is.factor(data$label)
data$label <- as.factor(data$label)

# Check class balanced or unbalanced
summary(data$label)

proportion <- prop.table(table(data$label)) * 100
cbind(count=table(data$label), proportion=proportion)

# Exploratory analysis on features

# Central 2*2 block of an image
central_block <- c("pixel376", "pixel377", "pixel404", "pixel405")
par(mfrow=c(2, 2))
for(i in 1:9) {
  hist(c(as.matrix(data[data$label==i, central_block])), 
       main=sprintf("Histogram for digit %d", i), 
       xlab="Pixel value")
}

# Using the caret package, separate the training and testing dataset.
set.seed(42)
train_perc = 0.75
train_index <- createDataPartition(data$label, p=train_perc, list=FALSE)
data_train <- data[train_index,]
data_test <- data[-train_index,]

# Multinomial logistic regression
model_lr <- multinom(label ~ ., data=data_train, MaxNWts=10000, decay=5e-3, maxit=100)
prediction_lr <- predict(model_lr, data_test, type = "class")
cm_lr = table(data_test$label, prediction_lr)
accuracy_lr = mean(prediction_lr == data_test$label)
accuracy_lr

# Single-layer neural networks
model_nn <- nnet(label ~ ., data=data_train, size=50, maxit=300, MaxNWts=100000, decay=1e-4)
prediction_nn <- predict(model_nn, data_test, type = "class")
cm_nn = table(data_test$label, prediction_nn)
accuracy_nn = mean(prediction_nn == data_test$label)
accuracy_nn

# Multiple hidden layer neural networks
data_train <- data.matrix(data_train)
data_train.x <- data_train[,-1]
data_train.x <- t(data_train.x/255)
data_train.y <- data_train[,1]

# Define and train the DNN model
data <- mx.symbol.Variable("data")
fc1 <- mx.symbol.FullyConnected(data, name="fc1", num_hidden=128)
act1 <- mx.symbol.Activation(fc1, name="relu1", act_type="relu")
fc2 <- mx.symbol.FullyConnected(act1, name="fc2", num_hidden=64)
act2 <- mx.symbol.Activation(fc2, name="relu2", act_type="relu")
fc3 <- mx.symbol.FullyConnected(act2, name="fc3", num_hidden=10)
softmax <- mx.symbol.SoftmaxOutput(fc3, name="sm")

devices <- mx.cpu()
mx.set.seed(42)
model_dnn <- mx.model.FeedForward.create(softmax, X=data_train.x, y=data_train.y,
                                         ctx=devices, num.round=30, array.batch.size=100,
                                         learning.rate=0.01, momentum=0.9,  eval.metric=mx.metric.accuracy,
                                         initializer=mx.init.uniform(0.1),
                                         epoch.end.callback=mx.callback.log.train.metric(100))

data_test.x <- data_test[,-1]
data_test.x <- t(data_test.x/255)
prob_dnn <- predict(model_dnn, data_test.x)
prediction_dnn <- max.col(t(prob_dnn)) - 1
cm_dnn = table(data_test$label, prediction_dnn)
accuracy_dnn = mean(prediction_dnn == data_test$label)
accuracy_dnn

# Convolutional neural networks
conv1 <- mx.symbol.Convolution(data=data, kernel=c(5,5), num_filter=20)
act1 <- mx.symbol.Activation(data=conv1, act_type="relu")
pool1 <- mx.symbol.Pooling(data=act1, pool_type="max",
                           kernel=c(2,2), stride=c(2,2))
conv2 <- mx.symbol.Convolution(data=pool1, kernel=c(5,5), num_filter=50)
act2 <- mx.symbol.Activation(data=conv2, act_type="relu")
pool2 <- mx.symbol.Pooling(data=act2, pool_type="max",
                           kernel=c(2,2), stride=c(2,2))
flatten <- mx.symbol.Flatten(data=pool2)
fc1 <- mx.symbol.FullyConnected(data=flatten, num_hidden=500)
act3 <- mx.symbol.Activation(data=fc1, act_type="relu")
fc2 <- mx.symbol.FullyConnected(data=act3, num_hidden=10)
softmax <- mx.symbol.SoftmaxOutput(data=fc2, name="sm")

train.array <- data_train.x
dim(train.array) <- c(28, 28, 1, ncol(data_train.x))
model_cnn <- mx.model.FeedForward.create(softmax, X=train.array, y=data_train.y,
                                         ctx=devices, num.round=30, array.batch.size=100,
                                         learning.rate=0.05, momentum=0.9, wd=0.00001,
                                         eval.metric=mx.metric.accuracy,
                                         epoch.end.callback=mx.callback.log.train.metric(100))

test.array <- data_test.x
dim(test.array) <- c(28, 28, 1, ncol(data_test.x))
prob_cnn <- predict(model_cnn, test.array)
prediction_cnn <- max.col(t(prob_cnn)) - 1
cm_cnn = table(data_test$label, prediction_cnn)
accuracy_cnn = mean(prediction_cnn == data_test$label)
accuracy_cnn

# Function to preprocess an image for model prediction
preprocess_image <- function(image_path) {
  img <- load.image(image_path)
  img <- grayscale(img)  # Convert to grayscale
  img <- resize(img, 28, 28)  # Resize to 28x28
  img <- as.numeric(img)  # Convert to numeric values
  img <- t(matrix(img, nrow = 28, byrow = TRUE))  # Convert to matrix format
  img <- img / 255  # Normalize pixel values
  return(img)
}

# Predict the digit from an image
predict_digit <- function(image_path, model) {
  img <- preprocess_image(image_path)
  dim(img) <- c(28, 28, 1, 1)  # Set the dimensions to match model input
  prob <- predict(model, img)
  prediction <- max.col(t(prob)) - 1  # Convert probabilities to class labels
  return(prediction)
}

# Example usage:
# Provide the path to the image
image_path <- "path/to/your/image.png"

digit_prediction <- predict_digit(image_path, model_cnn)
cat("The predicted digit is:", digit_prediction, "\n")