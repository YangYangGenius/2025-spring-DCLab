# Python script to read a .txt file, replace '\n' with actual new line, and write to a new .txt file

def replace_newline_in_file(input_file, output_file):
    try:
        # Open and read the input file
        with open(input_file, 'r', encoding='utf-8') as file:
            input_text = file.read()

        # Replace '\n' (literal string) with actual new line character
        output_text = input_text.replace(r'\n', '\n')

        # Write the modified text to the output file
        with open(output_file, 'w', encoding='utf-8') as file:
            file.write(output_text)

        print(f"File processed successfully. Output saved to {output_file}")

    except Exception as e:
        print(f"An error occurred: {e}")

# Example usage
input_file = './MAIN/src/LCD.txt'  # Replace with the path to your input file
output_file = './MAIN/src/LCD_output.txt'  # Replace with the desired output file path

replace_newline_in_file(input_file, output_file)
