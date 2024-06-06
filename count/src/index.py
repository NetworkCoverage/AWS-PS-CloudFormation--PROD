import copy
import json
import re

def process_template(template):
    new_template = copy.deepcopy(template)
    status = 'success'

    for name, resource in template['Resources'].items():
        if 'Count' in resource:
            #Get the number of times to multiply the resource
            count = new_template['Resources'][name].pop('Count')
            print("Found 'Count' property with value {} in '{}' resource....multiplying!".format(count,name))            
            #Remove the original resource from the template but take a local copy of it
            resourceToMultiply = new_template['Resources'].pop(name)
            #Create a new block of the resource multiplied with names ending in the iterator and the placeholders substituted
            resourcesAfterMultiplication = multiply(name, resourceToMultiply, count)
            if not set(resourcesAfterMultiplication.keys()) & set(new_template['Resources'].keys()):
                new_template['Resources'].update(resourcesAfterMultiplication)
            else:
                status = 'failed'
                return status, template
        else:
            print("Did not find 'Count' property in '{}' resource....Nothing to do!".format(name))
    return status, new_template

def update_placeholder(resource_structure, iteration):
    # Convert the json into a string
    resourceString = json.dumps(resource_structure)
    
    # Define a regular expression pattern to find string formatting operators for digits
    pattern = r'%(\d*)d'
    
    # Find all occurrences of the pattern in the string
    placeholders = re.findall(pattern, resourceString)
    
    # If placeholders are found, replace them with the iteration value
    if placeholders:
        print("Found {} occurrences of digit placeholders in JSON, replacing with iterator value {}".format(len(placeholders), iteration))
        for placeholder in placeholders:
            placeholder_value = str(iteration).zfill(int(placeholder)) if placeholder else str(iteration)
            resourceString = resourceString.replace('%{}d'.format(placeholder), placeholder_value)
        # Convert the string back to json and return it
        return json.loads(resourceString)
    else:
        print("No occurrences of digit placeholders found in JSON, therefore nothing will be replaced")
        return resource_structure


def multiply(resource_name, resource_structure, count):
    resources = {}
    #Loop according to the number of times we want to multiply, creating a new resource each time
    for iteration in range(1, (count + 1)):
        print("Multiplying '{}', iteration count {}".format(resource_name,iteration))        
        multipliedResourceStructure = update_placeholder(resource_structure,iteration)
        resources[resource_name+str(iteration)] = multipliedResourceStructure
    return resources


def handler(event, context):
    result = process_template(event['fragment'])
    return {
        'requestId': event['requestId'],
        'status': result[0],
        'fragment': result[1],
    }
