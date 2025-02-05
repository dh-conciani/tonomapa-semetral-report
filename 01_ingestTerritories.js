// prepare data
// create a image collection in which each territory is exported as a unique image containing their bounds and buffer zone
// dhemerson.costa@ipam.org.br

// input territories data as features
var input = ee.FeatureCollection('users/dh-conciani/help/tonomapa-reports/2025-01-15');

// build auxiliary as image
var input_image = ee.Image(1).clip(input);
Map.addLayer(input_image, {}, 'territories');

// set buffer zone size
var buffer_size = 10000;

// set output imageCollection
var output = 'users/dhconciani/2025-01-15-IC';

// compute buffers
//var buffers = input.map(function(feature) {
//  return feature.buffer(buffer_size);
//});

//Map.addLayer(buffers, {palette:['red'], min:3, max:3}, 'raw buffers');

// read input data
var data = ee.ImageCollection(
  input.map(function(feature) {
    // get ocjectid
    var obj = feature.get('ID_un');
    // compute buffer zone
    var buffer = feature.buffer(buffer_size)
      // and retain only difference (outer space)
      .difference(feature);
    // convert it to an image
    var image = ee.Image(1).clip(feature)
      .blend(ee.Image(2).clip(buffer))
      .set('territory', obj);
      
    // remove overlaps with other territories
    image = image.where(image.eq(2).and(input_image.eq(1)), 0).selfMask();
    
    // remove overlaps with other buffers
    
    
    return (image);
  })
);

print('raw', data);


data
  .aggregate_array('system:index')
  .evaluate(function(list){
    // print(list);
    
    list.forEach(function(index,count){
      var image = data.filter('system:index == "'+index+'"')
        .first();
     // print('image',image);
      Export.image.toAsset({
        image: image,
        description: '' + count,
        assetId: output + '/' + count,
        scale: 10,
        maxPixels: 1e13
        //region: image.geometry()
      });

    });
  });
