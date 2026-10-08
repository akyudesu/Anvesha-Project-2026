#!/usr/bin/env python3

import argparse
import os
import sys

try:
    import cv2
except ModuleNotFoundError as exc:
    raise SystemExit(
        "OpenCV is required. Install it with: pip install opencv-python-headless"
    ) from exc


def cell_label(row, col):
    """Return a grid label such as A1, B3, AA12."""
    letters = ""
    current = col

    while current >= 0:
        letters = chr(65 + (current % 26)) + letters
        current = current // 26 - 1
        if current < 0:
            break

    return f"{letters}{row + 1}"


def create_grid(image_path, rows, cols, output_dir, output_name="campus_grid.jpg"):
    if rows <= 0 or cols <= 0:
        raise ValueError("ROWS and COLS must both be greater than zero.")

    img = cv2.imread(image_path)
    if img is None:
        raise FileNotFoundError(f"Image could not be loaded from: {image_path}")

    height, width = img.shape[:2]
    cell_width = max(1, width // cols)
    cell_height = max(1, height // rows)

    os.makedirs(output_dir, exist_ok=True)
    grid_image = img.copy()

    for row in range(rows):
        for col in range(cols):
            x1 = col * cell_width
            y1 = row * cell_height
            x2 = (col + 1) * cell_width if col < cols - 1 else width
            y2 = (row + 1) * cell_height if row < rows - 1 else height

            cv2.rectangle(grid_image, (x1, y1), (x2, y2), (0, 0, 255), 2)

            label = cell_label(row, col)
            cv2.putText(
                grid_image,
                label,
                (x1 + 5, y1 + 25),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.7,
                (255, 0, 0),
                2,
            )

            cell = img[y1:y2, x1:x2]
            cell_filename = os.path.join(output_dir, f"{label}.jpg")
            cv2.imwrite(cell_filename, cell)

    output_path = os.path.join(os.getcwd(), output_name)
    cv2.imwrite(output_path, grid_image)

    print("Grid created successfully!")
    print(f"Grid image: {output_path}")
    print(f"Individual cells: {os.path.abspath(output_dir)}")

    return output_path


def parse_args():
    parser = argparse.ArgumentParser(description="Split an image into a grid and save each tile.")
    parser.add_argument("--image", default="image-1024.jpg", help="Path to the input image.")
    parser.add_argument("--rows", type=int, default=10, help="Number of rows in the grid.")
    parser.add_argument("--cols", type=int, default=10, help="Number of columns in the grid.")
    parser.add_argument("--output-dir", default="grid_cells", help="Folder to save individual grid cells.")
    parser.add_argument("--output-name", default="campus_grid.jpg", help="Filename for the overlaid grid image.")
    return parser.parse_args()


if __name__ == "__main__":
    try:
        args = parse_args()
        create_grid(args.image, args.rows, args.cols, args.output_dir, args.output_name)
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        raise SystemExit(1)
