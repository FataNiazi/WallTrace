def extract_and_append_room_numbers():
    # Read the existing content
    with open('roomLabels.txt', 'r') as file:
        lines = file.read().splitlines()

    # Extract room numbers (everything after first 2 characters)
    room_numbers = [line[2:] for line in lines if len(line) >= 2]

    # Prepare the output to append
    output = "\n".join(lines) + "\n\nExtracted room numbers:\n" + "\n".join(
        room_numbers)

    # Write back to the file
    with open('roomLabels.txt', 'w') as file:
        file.write(output)


extract_and_append_room_numbers()
