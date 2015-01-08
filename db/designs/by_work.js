"function(doc) {
  if (doc._id.indexOf('::v') == -1) {
    if (doc['@type'] === 'CreativeWork') {
      emit(doc['@id'],1);
    }

    if (doc['@type'] === 'WebPage' && doc.hasPart) {
      doc.hasPart.forEach(function(part) {
        emit(part.encodesCreativeWork,1)
      });
    }
  }
}"
