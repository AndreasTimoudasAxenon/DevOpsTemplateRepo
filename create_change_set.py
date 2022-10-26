import os
import sys
import argparse
import shutil


FILE_PATH = os.path.dirname(os.path.abspath(__file__))
APEX_CLASSES_PATH = os.path.join(FILE_PATH, 'force-app', 'main', 'default', 'classes')
APEX_TRIGGER_PATH = os.path.join(FILE_PATH, 'force-app', 'main', 'default', 'triggers')
FLOWS_PATH = os.path.join(FILE_PATH, 'force-app', 'main', 'default', 'flows')
OBJECTS_PATH = os.path.join(FILE_PATH, 'force-app', 'main', 'default', 'objects')

def generate_package_xml(files):
    os.mkdir('toDeploy')
    TARGET_DIR = os.path.join(FILE_PATH, 'toDeploy')
    print('*** Change Set Directory created: ./toDeploy')
    for key, value in files.items():
        if value:
            FILES_TO_FIND = [file.strip() for file in value.split(',')]
            if key == 'apex_classes':
                find_and_copy_apex(APEX_CLASSES_PATH, TARGET_DIR, FILES_TO_FIND)
            elif key == 'apex_triggers':
                find_and_copy_apex(APEX_TRIGGER_PATH, TARGET_DIR, FILES_TO_FIND)
            elif key == 'flows':
                find_and_copy_flow(FLOWS_PATH, TARGET_DIR, FILES_TO_FIND)
            else:
                find_and_copy_object(OBJECTS_PATH, TARGET_DIR, FILES_TO_FIND)
    print(os.listdir(TARGET_DIR))

def find_and_copy_apex(file_directory, target_directory, files_to_find):
    for file in os.listdir(file_directory):
        filename = os.path.splitext(file)[0]
        if filename in files_to_find:
            file_path = os.path.join(file_directory, file)
            xml_file = os.path.join(file_directory, f"{filename}.cls-meta.xml")
            shutil.copy(file_path, target_directory)
            shutil.copy(xml_file, target_directory)

def find_and_copy_flow(file_directory, target_directory, files_to_find):
    for file in os.listdir(file_directory):
        filename = file.split('.')[0]
        if filename in files_to_find:
            xml_file = os.path.join(file_directory, f"{filename}.flow-meta.xml")
            shutil.copy(xml_file, target_directory)

def find_and_copy_object(file_directory, target_directory, files_to_find):
    for file in os.listdir(file_directory):
        if file in files_to_find:
            xml_file = os.path.join(file_directory, file, f"{file}.object-meta.xml")
            shutil.copy(xml_file, target_directory)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--apex_classes')
    parser.add_argument('--apex_triggers')
    parser.add_argument('--flows')
    parser.add_argument('--objects')
    args = parser.parse_args()
    apex_classes = args.apex_classes
    apex_triggers = args.apex_triggers
    flows = args.flows
    objects = args.objects
    files = {'apex_classes': apex_classes, 'apex_triggers': apex_triggers, 'flows': flows, 'objects': objects}
    test = generate_package_xml(files)
