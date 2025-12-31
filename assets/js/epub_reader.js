document.addEventListener('selectionchange', () => {
  const selection = window.getSelection();
  if (selection.rangeCount > 0) {
    const range = selection.getRangeAt(0);
    const cfi = rendition.epubcfi.generate(range);
    const selectionData = {
      text: range.toString(),
      cfi: cfi,
    };
    AnnotationChannel.postMessage(JSON.stringify(selectionData));
  }
});

rendition.on('relocated', function(location){
  RelocatedChannel.postMessage(location.start.cfi);
});

window.applyAnnotation = (cfi, type, color) => {
  const range = new EPUB.CFI(cfi).toRange(document);
  const mark = document.createElement(type === 'highlight' ? 'mark' : 'span');
  if (type === 'highlight') {
    mark.style.backgroundColor = '#' + color.toString(16).padStart(8, '0').substring(2);
  } else {
    mark.style.textDecoration = 'underline';
  }
  range.surroundContents(mark);
};
