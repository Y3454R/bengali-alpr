# import utils

# # utils.show_image("images/test_image.jpg")

# utils.detect_and_extract_lp_text("images/test_image.jpg")

import time
import utils

start = time.time()

lp_text = utils.detect_and_extract_lp_text("images/test_image.jpg")
# lp_text = utils.detect_and_extract_lp_text("images/test_image_2.jpg")
# lp_text = utils.detect_and_extract_lp_text("images/test_image_3.jpg")

end = time.time()
print(f"Took {end - start:.2f} seconds")
print(lp_text)
