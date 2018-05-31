# Shopify Winternship 2018
# Colin Shum
# University of Waterloo

import json, requests

url = "https://backend-challenge-winter-2017.herokuapp.com/customers.json?page="

def api_data(page):
    return requests.get(url + str(page)).json()

def type_check(temp):
    # basic type checking function
    if isinstance(temp, str):
        return 'string'
    elif type(temp) == bool:
        return 'boolean'
    elif isinstance(temp, int):
        return 'number'
    else:
        return 'none'


def validate_rule(field_name, rules, value):

    # selects the validation rules based upon field
    validations = rules[field_name]

    # empty but required fields
    if 'required' in validations and (value == None) and validations['required']:
        return False

    if 'type' in validations:
        if type_check(value) != validations['type']:
            return False

    if 'length' in validations:
        # rejects field if it has property of 'length' but is not a string type
        if type_check(value) != 'string':
            return False

        else:
            # length comparisons
            if 'length' in validations:
                if 'min' in validations['length']:
                    minimum = validations['length']['min']
                else:
                    minimum = 0

                if len(value) < minimum:
                    return False

                if 'max' in validations['length']:
                    maximum = validations['length']['max']
                    if len(value) > max:
                        return False

    return True


def cust_validation(customer, validation):
    violations = []

    for rule in range(len(validation)):
        # collects first key as list object
        field = list(validation[rule].keys())[0]
        temp = validate_rule(field, validation[rule], customer[field])

        # appends failed validations to a list
        if temp == False:
            violations.append(field)
    return violations


def main():
    output = {"invalid_customers": []}
    page = 1

    while(True):
        resp = api_data(page)

        # emulate a do-while loop with a while(true) loop
        # break if customers is empty
        if (resp['customers'] == []):
            break
        else:
            for user in resp['customers']:
                violations = cust_validation(user, resp['validations'])
                if violations != []:
                    output['invalid_customers'].append({'id': user['id'], 'invalid_fields': violations})

            page += 1

    print(json.dumps(output))

main()
