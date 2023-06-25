#!/usr/bin/python3
# Simple Program utilizing the urllib library to encode and decode url

def encodeURLString():
    from urllib.parse import quote
    strToEncode = str(input('\nEnter String: '))
    encdedStr = quote(strToEncode)
    return encdedStr

def decodeURLString():
    from urllib.parse import unquote
    strToDecode = str(input('\nEnter String: '))
    decdedStr = unquote(strToDecode)
    return decdedStr

def optionCase(optionchosen):
    if optionchosen == 1:
        print(encodeURLString())
    elif optionchosen == 2:
        print(decodeURLString())
    else:
        print('Something Went Wrong')

if __name__ == "__main__":
    print('\nScript Running As Main\n')
    print('\nPress 1 : For Encoding URL\nPress 2 : For Decoding URL\n')

    try:
        optionchosen = int(input('Choice: '))
        optionCase(optionchosen)
    except TypeError as e:
        print('Exception:',e)
    except KeyboardInterrupt:
        print('\nInterrupt Received \nEnding Program')
    except ValueError:
        print('Invalid Value')

    
