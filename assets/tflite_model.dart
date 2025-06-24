import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

class RecipeModel {
  late Interpreter interpreter;
  late TensorImage inputImage;
  late TensorBuffer outputBuffer;

  Future<void> loadModel() async {
    // Load the model
    interpreter = await Interpreter.fromAsset('recipe_model.tflite');
    print('✅ TFLite model loaded!');

    // Optional: Allocate tensors explicitly (depends on model)
    interpreter.allocateTensors();

    // Setup input/output buffers if needed
    var inputShape = interpreter.getInputTensor(0).shape;
    var inputType = interpreter.getInputTensor(0).type;

    var outputShape = interpreter.getOutputTensor(0).shape;
    var outputType = interpreter.getOutputTensor(0).type;

    inputImage = TensorImage(inputType);
    outputBuffer = TensorBuffer.createFixedSize(outputShape, outputType);
  }

  // Predict using processed input data
  Future<List<double>> predict(List<double> inputData) async {
    // Convert input data to Float32 TensorBuffer
    TensorBuffer inputBuffer = TensorBuffer.createFixedSize(
      [1, inputData.length],
      TfLiteType.float32,
    );
    inputBuffer.loadList(inputData);

    // Run inference
    interpreter.run(inputBuffer.buffer, outputBuffer.buffer);

    // Return predictions as a List<double>
    return outputBuffer.getDoubleList();
  }
}
