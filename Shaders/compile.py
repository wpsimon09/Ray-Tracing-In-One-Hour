import os
import subprocess
import sys


# Path to the Slang compiler (edit this if slangc isn't in your PATH)
SLANGC_PATH = r"/home/wpsimon09/SDKs/slang/bin/slangc" 

# Shader source file
INPUT_FILE = "main.slang"

# Output directory for SPIR-V files
OUT_DIR = "spirv"

# === MAIN ===

def compile_shader(entry, output_name):
    """Compile a shader entry point using slangc"""
    output_path = os.path.join(OUT_DIR, output_name)

    cmd = [
        SLANGC_PATH,
        INPUT_FILE,
        "-target", "spirv",
        "-entry", entry,
        "-o", output_path
    ]

    print(f"Compiling {entry} -> {output_path}")
    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        print(f"Error compiling {entry}:")
        print(result.stderr)
        sys.exit(result.returncode)
    else:
        print(f" Successfully compiled {output_name}")

def main():
    if not os.path.exists(SLANGC_PATH):
        print(f" slangc not found at: {SLANGC_PATH}")
        print(" Please update SLANGC_PATH to the correct location.")
        sys.exit(1)

    if not os.path.exists(INPUT_FILE):
        print(f" Input file '{INPUT_FILE}' not found.")
        sys.exit(1)

    os.makedirs(OUT_DIR, exist_ok=True)

    compile_shader("vertexMain", "vertex.spv")
    compile_shader("fragmentMain", "fragment.spv")

    print("\n All shaders compiled successfully!")

if __name__ == "__main__":
    main()
