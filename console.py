import numpy as np
# from io import StringIO
# import pandas as pd
import tensorflow as tf
print(tf.version.VERSION)
# import tensorflow_datasets as tfds
from tensorflow import keras
from tensorflow.keras import backend as K

batch_size=1024
test_data_ratio=.2 # 数据中test dataset的占比
checkpoint_path = ".\\TFcheckpoint\\cp.ckpt"
cp_callback = tf.keras.callbacks.ModelCheckpoint(
    filepath=checkpoint_path, 
    verbose=1, 
    save_weights_only=True,
    save_freq=5*batch_size)

class Mk1(tf.keras.Model):
    def __init__(self):
        super(Mk1, self).__init__()
        self.rnn=tf.keras.layers.LSTM(3,return_sequences='true',activation='sigmoid')
        self.rnn2=tf.keras.layers.LSTM(9,return_sequences='true',activation='sigmoid')
        self.dense1=tf.keras.layers.Dense(3,activation='sigmoid')

    def call(self,inputs):
        x1,x2,x3=tf.split(inputs,num_or_size_splits=3,axis=2)
        y1=self.rnn(x1)
        y2=self.rnn(x2)
        y3=self.rnn(x3)
        y4=tf.concat([y1,y2,y3],axis=2)
        y5=self.rnn2(y4)
        y = self.dense1(y5)
        return y

X=np.genfromtxt('.\\data.txt',delimiter=",")
# 数据各列意义：
# 0：时间，用不上
# 1-3：重力计
# 4-6：陀螺仪
# 7-9：磁力计
# 10-12：Position Groundtruth
# 13-15：Orientation Groundtruth
x=X[:,range(1,10)] # 输入数据
y_ori=X[:,range(13,16)] # groundtruth

# 分batch，分完之后x会变成list类型
x=np.split(x,batch_size) 
y_ori=np.split(y_ori,batch_size)
# 把list转回array
x=np.array(x) 
y_ori=np.array(y_ori)
# 按照test集占比划分test和train数据集
xt=x[:,int(np.shape(x)[1]-(np.shape(x)[1]*test_data_ratio)):np.shape(x)[1],:]
yt_ori=y_ori[:,int(np.shape(y_ori)[1]-(np.shape(y_ori)[1]*test_data_ratio)):np.shape(y_ori)[1],:]
x=x[:,0:int(np.shape(x)[1]-(np.shape(x)[1]*test_data_ratio)),:]
y_ori=y_ori[:,0:int(np.shape(y_ori)[1]-(np.shape(y_ori)[1]*test_data_ratio)),:]
# Numpy array转为TensorFlow的tensor作为输入
x=tf.convert_to_tensor(x, np.float32)
y_ori=tf.convert_to_tensor(y_ori, np.float32)
xt=tf.convert_to_tensor(xt, np.float32)
yt_ori=tf.convert_to_tensor(yt_ori, np.float32)
# 神经网络
nn=Mk1()
nn.compile(optimizer="sgd", loss='mse') 
nn.load_weights(checkpoint_path)
print('History model loaded from:',checkpoint_path)
nn.fit(x,y_ori,epochs=10,callbacks=[cp_callback])

# nn.predict(xt)

# test module

# results = nn.evaluate(xt, yt_ori)

nn.predict(xt[:,1:2,:])

