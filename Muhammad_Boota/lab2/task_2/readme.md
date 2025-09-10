# Binary Coded Decimal (BCD) Converter

## Overview
This project implements a combinational logic circuit to convert an 8-bit binary input (range 0-255) into a 3-digit BCD (Binary Coded Decimal) output, also ranging from 000 to 255.

## Design Requirements
- **Input**: 8-bit binary value (`binary_in`)
- **Output**: 3-digit BCD value (`bcd_out`)
- **Conversion**: Purely combinational implementation
- **Input Range**: 0 to 255
- **Output Range**: 000 to 255 in BCD format

## Functionality
The converter takes an 8-bit binary input and transforms it into a 3-digit BCD representation. Each digit of the BCD output corresponds to a decimal value from 0 to 9, ensuring accurate representation of the binary input within the specified range.

## Implementation Notes
- The design uses combinational logic to perform the conversion without sequential elements.
- The output is structured as three BCD digits, each represented by 4 bits.

## Usage
- Connect the 8-bit `binary_in` signal to the input of the converter.
- The `bcd_out` signal will provide the 3-digit BCD representation of the input value.

## Diagram
![BCD Converter Diagram](/Muhammad_Boota/lab2/task_2/docx/binary_to_bcd.png)