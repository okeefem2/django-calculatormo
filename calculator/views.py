from django.shortcuts import render

from django.http import HttpResponseRedirect, HttpResponse
from django.template import loader
from django.core.urlresolvers import reverse
from django.shortcuts import get_object_or_404, render
from django.views import generic
from .models import Answer, Equation
from django.utils import timezone
# Create your views here.
from django import forms

###################################################################################################

def calc_answer(arg1, arg2, equation_type):

    if equation_type == 'addition':
        A = Answer.objects.create(answer_value=(arg1+arg2))
        eq = str(arg1) + ' + ' + str(arg2) + ' = ' + str(A.answer_value)
        E = Equation.objects.create(answer=A, equation_text=eq)

    if equation_type == 'subtraction':
        A = Answer.objects.create(answer_value=(arg1-arg2))
        eq = str(arg1) + ' - ' + str(arg2) + ' = ' + str(A.answer_value)
        E = Equation.objects.create(answer=A, equation_text=eq)


    if equation_type == 'multiplication':
        A = Answer.objects.create(answer_value=(arg1*arg2))
        eq = str(arg1) + ' * ' + str(arg2) + ' = ' + str(A.answer_value)
        E = Equation.objects.create(answer=A, equation_text=eq)


    if equation_type == 'division':
        A = Answer.objects.create(answer_value=(arg1/arg2))
        eq = str(arg1) + ' / ' + str(arg2) + ' = ' + str(A.answer_value)
        E = Equation.objects.create(answer=A, equation_text=eq)


#    else:
#
    return A.id

###################################################################################################

class CalcForm(forms.Form):
    arg1 = forms.CharField(max_length=200)
    arg2 = forms.CharField(max_length=200)

###################################################################################################

def formview(request):
    if request.method == 'POST':
        form = CalcForm(request.POST)

        if form.is_valid():

            arg1 = form.cleaned_data['arg1']
            arg2 = form.cleaned_data['arg2']
            # get choice from radio buttons
            equation_type = request.POST['choice']

            try:
                arg1 = float(arg1)
                arg2 = float(arg2)
            except:
                # have an error output for non numerical inputs
                pass

            answer_id = calc_answer(arg1, arg2, equation_type)

            return HttpResponseRedirect(reverse('calculator:answer', args=(answer_id,)))


    return render(request, 'calculator/form.html')

###################################################################################################

def answer(request, answer_id):

    answer = get_object_or_404(Answer, pk=answer_id)
    equation = answer.equation_set.all()
    return render(request, 'calculator/answer.html', {'equation': equation[0].equation_text})

###################################################################################################

def results(request):
    answer_list = Answer.objects.all()
    equation_list = []
    for answer in answer_list:
        equation = answer.equation_set.all()[0]
        equation_list.append(equation)
    return render(request, 'calculator/results.html', {'equation_list': equation_list})
