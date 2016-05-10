from django.contrib import admin

# Register your models here.

from .models import Answer, Equation

class EquationInline(admin.TabularInline):
    model = Equation
    extra = 1

class AnswerAdmin(admin.ModelAdmin):
    fieldsets = [
        ('Answer',               {'fields': ['answer_value']}),

    ]
    inlines = [EquationInline]

admin.site.register(Answer, AnswerAdmin)
