from django.db import models

# have an answer class, and an equation class
# they will be linked like question and choice from polls

class Answer(models.Model):
    answer_value = models.FloatField()

    def __str__(self):
        return str(self.answer_value)

    def get_num(self):
        answer_num = float(self.answer_value)
        return answer_num

class Equation(models.Model):
    answer = models.ForeignKey(Answer, on_delete=models.CASCADE)
    equation_text = models.CharField(max_length=200)

    def __str__(self):
        return self.equation_text


    def type(self):
        if (equation_text.find('+')):
            return 'Addition'
        else:
            return 'Unsupported equation'
