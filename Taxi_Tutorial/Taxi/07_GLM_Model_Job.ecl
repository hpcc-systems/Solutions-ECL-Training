IMPORT Taxi;
IMPORT ML_Core;
IMPORT GLM;
IMPORT ML_Core.Types AS Core_Types;  

ds := Taxi.Files.taxi_train_ds;
ML_Core.AppendSeqID(ds, id, ds_seq);      // label the rows with sequence numbers

ML_Core.toField(ds_seq, explanatory, id, , , 'pickup_day_of_week,pickup_month,pickup_year');
ML_Core.toField(ds_seq, dependent, id, , , 'cnt');

PoissonSetup := GLM.GLM(explanatory, dependent, GLM.Family.Poisson);
PoissonModel := PoissonSetup.GetModel();
PoissonPreds := PoissonSetup.Predict(explanatory, PoissonModel);
PoissonDeviance := GLM.Deviance_Detail(dependent, PoissonPreds, PoissonModel, GLM.Family.Poisson);

OUTPUT(GLM.ExtractBeta_full(PoissonModel), NAMED('Model')); 
OUTPUT(PoissonPreds, NAMED('Preds'));
OUTPUT(PoissonDeviance, NAMED('Deviance'));  

