import tensorflow as tf

class Mk1(tf.keras.Model):
    def __init__(self):
        super(Mk1, self).__init__()
        self.rnn=tf.keras.layers.LSTM(3,return_sequences='true',activation='sigmoid')
        self.dense1=tf.keras.layers.Dense(4,activation='sigmoid')

    def call(self,inputs):
        x1,x2,x3=tf.split(inputs,num_or_size_splits=3,axis=2)
        # print('*****x1:',x1.get_shape)
        # print('**********x2:',x2.get_shape)
        # print('********************x3:',x3.get_shape)
        y1=self.rnn(x1)
        y2=self.rnn(x2)
        y3=self.rnn(x3)
        # print('********************y1:',y1.get_shape)
        # print('*************************y2:',y2.get_shape)
        # print('******************************y3:',y3.get_shape)
        y4=tf.concat([y1,y2,y3],axis=2)
        # print('***********************************y4:',y4.get_shape)
        y = self.dense1(y4)
        # print('****************************************y:',y.get_shape)
        return y
