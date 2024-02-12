# Compile resources before running application in case any files were modified
pyside6-rcc src/qterm/resources/resources.qrc -o src/qterm/resources/resources.py
briefcase dev
