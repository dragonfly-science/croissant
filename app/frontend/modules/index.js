import $ from 'jquery';

const modules = require.context('.', true, /\.js$/);
modules.keys().forEach(modules);

import TaggedSubmissionText from './tagged_submission_text';
import TaggableSubmissionText from './taggable_submission_text';

$(document).ready(() => {
  let taggedSubmissionText = new TaggedSubmissionText('.js-tagged-submission');
  taggedSubmissionText.renderAllTags();

  new TaggableSubmissionText(
    '.js-taggable-submission-text',
    taggedSubmissionText
  );
});
