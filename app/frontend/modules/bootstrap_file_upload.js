import $ from 'jquery';

$(document).ready(() => {
  $('.custom-file-input').on('change', e => {
    const fileName = e.target.files[0].name;
    $(`.custom-file-label[for=${e.currentTarget.id}]`).html(fileName);
  });
});
