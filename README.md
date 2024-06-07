
# Julia Set Generator

### Author: Rafał Mironko

---

## Project Description

**Julia Set Generator** is a program written in RISC-V assembly that generates a bitmap of the Julia set based on given initial data. The program prompts the user to input the real and imaginary parts of a constant, and then generates an image of the Julia fractal in .bmp format.

## Julia Algorithm

The Julia set is generated based on the iteration of a complex function. For each point \((x, y)\) in the complex plane, the iteration follows the formula:

\[
z_{n+1} = z_n^2 + c
\]

where \(z\) is a complex number, and \(c\) is a complex constant specified by the user. Initially, \(z_0\) is equal to the coordinates of the point \((x, y)\). If the sequence \(|z_n|\) does not exceed a certain limit (e.g., 2) after a specified number of iterations, the point \((x, y)\) is part of the Julia set.

## Features

- **Julia Set Generation**: The program computes and generates the Julia fractal.
- **Interactive Input**: The user inputs the real and imaginary parts of the complex constant.
- **High Performance**: Using RISC-V assembly maximizes performance during fractal generation.

## Requirements

- **RARS (RISC-V Assembler and Runtime Simulator)**: For compiling and running the program.
- **.bmp Image Viewer**: To open the generated `output.bmp` file.

## Installation

1. **Download and install RARS**: [Download RARS](https://github.com/TheThirdOne/rars/releases).
2. **Clone the repository**:
   ```sh
   git clone https://github.com/your_repository/julia-set-generator.git
   cd julia-set-generator
   ```

## Usage

1. Open the assembly file in RARS.
2. Run the program to generate the `output.bmp` file.
3. Open `output.bmp` with any image viewer.

## Author

Rafał Mironko
