# AutoPA
A software package for automatic extraction of pre-aspiration from speech segments in audio files,  using a trainable algorithm.

The package is based on AutoVot project - automatic extraction of voice onset time (VOT) from audio 
files (2014 Joseph Keshet, Morgan Sonderegger, Thea Knowles). The core implemantion of AutoVot was used
to train a new model for the task of pre-aspiration detection. Some of the cpp files were changed
to fit the new task. In addition, some of the wrapper python files were changed and many new tools and 
tests were added (mainly python and bash scripts).

It works as follows:
* The user provides wav files containing a sequences of sonorants and voiceless obstruents, and corresponding Praat TextGrids containing some information about roughly where the pre-aspiration should be (e.g. the preceding phoneme and the obstruent).
* A classifier is used to find the pre-aspiration for each obstruent, and add a new tier to each TextGrid containing these measurements.
* The user can either use a pre-existing classifier, or (recommended) train a new one using a manually-labeled pre-aspirations from their own data.
