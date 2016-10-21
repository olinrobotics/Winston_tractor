function pb = pbSetImg(pb, img)
assert(isa(img, 'uint8'));
[steps, strides, layers] = size(img);
img = typecast(img(:), 'int8');
pb.setSteps(steps);
pb.setStrides(strides);
pb.setLayers(layers);
pb.setData(pb.getData().copyFrom(img));
end
