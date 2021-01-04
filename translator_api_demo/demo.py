import json
from ibm_watson import LanguageTranslatorV3
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator

api_key_json_file = "apikey.json"
service_url = "https://api.eu-gb.language-translator.watson.cloud.ibm.com/instances/c6b84156-6dd7-43cc-823d-719270063d12/"
source_text = "A niechaj narodowie wżdy postronni znają, iż Polacy nie gęsi, iż swój język mają"
transl_config = "lt-en"
translator_version = "2018-05-01"
detected_lang_cnt = 10
destination_lang = "en"

def main():
    print("IBM Watson translator demo\n")
    print("Text to translate: \"{}\"\n".format(source_text))

    api_key = read_api_key(api_key_json_file)
    authenticator = IAMAuthenticator(api_key)

    language_translator = LanguageTranslatorV3(version=translator_version,
                                               authenticator=authenticator)

    language_translator.set_service_url(service_url)

    detected_lang_json = language_translator.identify(source_text).get_result()
    print("Language detection")
    print("List of 5 most probable langauages of translated text:")

    for i in range(detected_lang_cnt):
        lang = detected_lang_json["languages"][i]["language"]
        detection_confidence = detected_lang_json["languages"][i]["confidence"] * 100
        print("{}. {} - confidence: {} %".format(i + 1, lang, detection_confidence))

    source_lang = detected_lang_json["languages"][0]["language"]
    source_confidence = detected_lang_json["languages"][0]["confidence"] * 100
    print("Taking best match \"{}\" with {}% confidence".format(source_lang, source_confidence))

    sup_lang_json = language_translator.list_identifiable_languages().get_result()

    found = False
    for i in range(len(sup_lang_json["languages"])):
        if sup_lang_json["languages"][i]["language"] == source_lang:
            print("Matched language is {} and it is supported, Hurray!\n".format(sup_lang_json["languages"][i]["name"]))
            found = True
            break
    if not found:
        raise NameError("Matched language ({}) is not supported".format(source_lang))

    transl_config = source_lang + "-" + destination_lang
    print("Translation configuration: {}\n".format(transl_config))

    transl_json = language_translator.translate(text=source_text,
                                                model_id=transl_config).get_result()
    destination_text = transl_json["translations"][0]["translation"]
    destination_word_cnt = transl_json["word_count"]
    destination_char_cnt = transl_json["character_count"]
    print("Translated text: \"{}\"\nWord count: {}\nCharacter count: {}".format(destination_text, destination_word_cnt, destination_char_cnt))


def read_api_key(api_key_json_file):
    with open(api_key_json_file, "r") as akjf:
        akj = json.load(akjf)
        api_key = akj["apikey"]

    return api_key

if __name__ == "__main__":
    main()
