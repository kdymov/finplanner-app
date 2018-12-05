from django.db import models
from django.contrib.auth.models import User

# Create your models here.

class Account(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    limit = models.FloatField()


class OutcomeType(models.Model):
    type = models.CharField(max_length=200)


class Outcomes(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    type = models.ForeignKey(OutcomeType, on_delete=models.CASCADE)
    date = models.DateField()
    amount = models.FloatField()
