#! /bin/bash
# brief: Import various CNN models from the web
# author: Andrea Vedaldi

# Models are written to <MATCONVNET>/data/models
# You can delete <MATCONVNET>/data/tmp after conversion

# TODO apply patch to prototxt which will resize the outputs of cls layers from 205 -> 1000 (maybe sed?)

CAFFE_URL=http://dl.caffe.berkeleyvision.org/
GOOGLENET_PROTO_URL=http://vision.princeton.edu/pvt/GoogLeNet/ImageNet/train_val_googlenet.prototxt
GOOGLENET_MODEL_URL=http://vision.princeton.edu/pvt/GoogLeNet/ImageNet/imagenet_googlenet.caffemodel
GOOGLENET_MEAN_URL=http://vision.princeton.edu/pvt/GoogLeNet/ImageNet/imagenet_mean.binaryproto

# Obtain the path of this script
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

converter="python $SCRIPTPATH/import-caffe.py"
data="$SCRIPTPATH/../data"

mkdir -p "$data"/{tmp/googlenet,models}

# --------------------------------------------------------------------
# VGG Very Deep
# --------------------------------------------------------------------

if true
then
    (
        # we need this for the synsets lits
        cd "$data/tmp/caffe"
        wget -c -nc $CAFFE_URL/caffe_ilsvrc12.tar.gz
        tar xzvf caffe_ilsvrc12.tar.gz
        # deep models
        cd "$data/tmp/googlenet"
        wget -c -nc $GOOGLENET_PROTO_URL
        wget -c -nc $GOOGLENET_MODEL_URL
        wget -c -nc $GOOGLENET_MEAN_URL
    )
fi

if true
then
    base="$data/tmp/googlenet/"
    in=(imagenet_googlenet)
    out=(googlenet)
    synset=(caffe)

    for ((i=0;i<${#in[@]};++i)); do
        out="$data/models/imagenet-${out[i]}.mat"
        if test ! -e "$out" ; then
            echo $converter \
                --caffe-variant=caffe_0115 \
                --preproc=caffe \
		--no-remove-dropout \
                --average-image="$base/imagenet_mean.binaryproto" \
                --synsets="$data/tmp/${synset[i]}/synset_words.txt" \
                "$base/train_val_googlenet.prototxt" \
                "$base/imagenet_googlenet.caffemodel" \
                "$out"
        else
            echo "$out exists"
        fi
    done
fi
