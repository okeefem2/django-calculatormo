from django.test import TestCase

class CalculatorTest(TestCase):

    def test_answer_value(self):

        answer = Answer(answer_value=15.0)
        self.assertEqual(answer.answer_value, 15.0)

    
