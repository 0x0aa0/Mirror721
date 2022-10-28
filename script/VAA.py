import string
from urllib.request import urlopen
import json
import argparse
import base64
from hexbytes import HexBytes

def main(args): 
    fetchVAA(args)

def fetchVAA(args):
    url = "https://wormhole-v2-testnet-api.certus.one/v1/signed_vaa/{}/{}/{}".format(args.chain, args.address, args.pos)
    response = urlopen(url)
    data_json = json.loads(response.read())
    output = base64.b64decode(data_json["vaaBytes"]).hex()
    print("0x" + output)

def parse_args(): 
    parser = argparse.ArgumentParser()
    parser.add_argument("--chain", type=str)
    parser.add_argument("--address", type=str)
    parser.add_argument("--pos", type=str)
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_args() 
    main(args)