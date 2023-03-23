#!/bin/bash
# $1 => project name
#!/bin/bash

# Check if virtual environment is already activated
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "Deactivating virtual environment..."
    deactivate
fi

# Create a new virtual environment
echo "Creating virtual environment..."
python3 -m venv env
source env/bin/activate

# Install Django
echo "Installing Django..."
pip3 install django

# Create a new Django project
echo "Creating Django project..."
mkdir $1
cd $1
mkdir $1
# NAME => $1
