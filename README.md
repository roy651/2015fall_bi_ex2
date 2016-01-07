#RandomForest
###Haifa University / Fall 2015 / BI / EX2 / ID:029587391

##Overview
This project implements a Random Forest algorithm consisting of either Decision trees or Regression trees. The project is written in Ruby, which is a very expressive language, strong in its functional affiliation and weak in its object oriented tendancies. The program runs on the ruby interpreter (ruby or irb). In order to run it, one must call the run() function on the EX2Main module. This function receives several paramemters, by this order:
- Training file path
- Test file path
- Number of trees to build in the forest
- Maximal depth of the tree
- Number of records to randomize per tree - Defaults to the number of records in the training set if the value is less than or equal to zero
- Number of features to select randomly in each level of the tree
- Minimal number of records for the stop condition in a leaf of the tree
- Random seed (Optional)

##Structure
###main.rb
The main file of the program containg the EX3Main module which is the main controller of the flow of the program. This module contains a single function, run(), which is the function called from the outside to intialize the process. 
In side this function you may find all the top level function calls, controlling the flow of the program: Reading the files, Building the forest, Testing the forest and printing the results.
Underneath this function you may find several convenience calls to launch this program from the ruby executable instead of from the irb interpreter

###utils.rb
Various utility functions used by more than one module or pushed aside from the main flow of the code to enhance clarity of the code and cleanliness

###tree_builder.rb
Actually a forest-builder. Called from the main module, this module starts a top level iteration on the defined number of trees and constructs them all. Each tree is constructed from the root node down to the leaves in a classic recursive manner. 
Each now starts his "life" as a leaf and gets tested for the stop condition to determine if it is indeed a leaf. If not, an attempt is then made to find the optimal split on this node. 
The optimal split is identified by running, first, an iteration on several randomly selected features. At each iteration of a feature we then run an internal iteration on all possible splits of the sorted vector of that specific feature, while keeping the best split of the double-iteration. This split is considered the optimal split for that node and therefore we construct the node accordingly and continue to the child nodes in the same (recursive manner).
The heart of the entire algorithm, which sits at the center of the iteration is the function which determines what is the purity gain acheived by that split. This purity gain is calculated by reducing the sum of purity of the left and right sides of the split vector (with regards to the the class/results vector of the data) from the purity score of the parent set (again with regards to the class/results vector of that set).
This purity function can either be calculated by using a Gini function - for decision trees or by using the standard deviation - for regression trees. The specific function is determined at run time and passed to the generic gain function to call upon.
An interesting optimization I introduced at the last minute was that the calculation of the actual purity (either by Gini or STD DEV) is done in an incremental manner, thus reducing these multi-millions calls (literally!), from o(n) to o(1). Further elaboration below in the performance section.

###tree_node.rb
A class (the only class in this project) which is used to model the hierarchy of the decision tree. Very unlike-Ruby but very suitable for the data structure at hand, a class hierarchy has the capacity to hold both properties and references to child (parent?) nodes, while at the same time able to operate of its content in a specific node context to be able to "decide" when presented with a test sample.
Additionally, this tree node is capable of printing it self in awesome ascii format and the best part is that thanks to OO's polymorphysm we can utilize the tree and only at runtime decide whether we're using it as a classid\fied decision tree or as a regression decision tree.

###tree_tester.rb
This module iterates over the test records and then over each one of the trees in the forest, requesting their decision on the current sample and aggregating the votes of the entire forest with regards to the specific sample.
It then proceeds to calculate both the entire forest error rate and the progressing error of the trees in the forest, in an attempt to show that the more trees we use the more accurate the algoritm gets, up to a point in which overfitting is encoutered, which leads to a slight deterioration in the accuracy of the forest.
This effect is somewhat evident in the graphs on the N-dimensions error rate of the trees (in the attached excel sheet)

###tree_analyzer.rb
Is a simple module aimed at calculating the impact (rank) of each feature in the tree by viewing the occurences of each feature in the forest and scoring it aggregatively according to its proximity to the root of the tree, in a logerithmic scale.
So a feature at the root of the tree would score 1 point while the 2 features at the second level would each score 1/2 point and on the 3rd level 1/4 point and so on.
The output of the rank is attached at the end of the output of each forest run and it presents an array of dous. Each dou is a couple of a feature and its score. All features are sorted accordingto the descending order of their score.

##Analysis
Most of the effort in this project went, initially, towards understanding the exercise and then thoroughly understading the algorithms. Once that was achieved, The implementation was relatively the easy part. In the end, of course, a sizeable amount of time was devoted to bugs, both programmatic and algorithmic.
Some interesting bugs which I've had:
- Initially I failed to notice the fact that the features are allowed to be used more than once during the construction of the tree - this bug had a substantial negative effect on my results for the 2D sample (clearly, as it basically didn't allow the tree to contain more tha 2 nodes in depth), but only a relatively minor negative effect of the multiple dimensions samples.
- A second algorithmic bug I had was that I failed to understand that the trees needed to be constructed of N randomly selected records out of N records (with repetitions) and simply selected the number of records as an input parameter. This solution worked reasonably well in the 2D sample but failed to come close at the larger dimensions
- An interesting programmatic bug that I ran into occured while calculating the standard deviation of the sets, when, in some cases, I had only identical values within the set and due to float rounding issues - the deviation which should have been zero, would become the result of a squared root of a negative number... This was solved using a simple rounding.

##Parameters effect
Naturally, each parameter had its effect on the result in its turn. Some of them had significant effect up to a point and then they had almost no effect - e.g. depth. Others, like the minimal size of a set (for the stop condition) had a reverse parabolic behaviour, where they would improve the result as I lowered the value but then lowering it further (usually under 5 per set) would clearly bear a negative effect (probably over fitting..)
As per the number of the records per tree (which was meant to be set at N all the time) - that clearly had the most significant effect on the result, probably because the learning algorithm didn't have the full view of the result set. Interesting to see, that running the train set on a limited number of records from the set leads to slightly better results than the test set, but running the full N (randomly selected) records yields a massive improvement (nearly 0 errors) on the training set and good improvement on the test set as well.

##Error analysis
In the (attached excel) 2D graph it is easy to see in gray the 3 distinct groups of classes as three smears  of stains which overlap each other. It is further enlightning to observe that almost all of the algorithm's error are set exactly at the intersection/overlap between the different classes and it is quite obvious that no man (or algorithm) would have an easy time trying to distinguish one group from the other at those areas.
Another interesting observation can be made on the progressive error of the forest: As the forest increases in size the error rate descends rapidly, up to a point (the bottom of the parabolic curve) where it reaches a minimum and then additional trees do not improve and in certain case may lead to a deterioration of the accuracy of the forest's prediction, probably due to over-fitting.
The progressive output of the errors of the trees is attached at the bottom of the output of each run of the forest (in the attached files)
For simple clasification decision trees, the error is expressed simply as the number of errors (can be compared to the number of records in the test set).
for regressional decision trees the error is basically the standard deviation of the prediction compared to the actual result (square-root of the mean of the sum of squared delta between the predicion and the actal)

##Performance
My project is written in Ruby and it is probably the only one written in Ruby for this purpose as it is a poor choice... On one hand I had a great time writing in Ruby - That enabled me to develop my Ruby skills and proficiency (which I needed anyway for my work). But on the other hand I've paying a penalty in the performance of the solution.
A profiler's analysis of a running of the code showed that, as predicted, there are (literally) millions of calls concentrated at the heart of the algorithm: the calculation of the purity (for decision trees) or the std deviation (for regression trees). The effect of sorting and splitting the arrays in half (multiple times) and then counting the occurences for the purpose of calculating the probability (for the Gini function), was horrific. 
Encouraged by Prof. Shimshoni's hint to replace the full calculation with an incremental calculation, I sat down and refactored my code in a way that only the first cycle at each node and each feature performs the full purity calculation. Subsequent iterations aiming to choose the best split, no longer have to perform a full o(n) scan in order to do the calculation. 
Instead, each iteration passes on to the next iteration a "memory" object which holds the previous result and intermediate values to help perform the subsequent operation.
Thus this inner operation runs at o(1) instead of o(n), which lead to an overall improvement in the algorithm runtimes on a scale of 10^2-10^3
Bottom line: the performance is still poor compare to Weka (or to other Java implementations, but the scale is no longer substantial and I attribute this deficiancy mostly to the performance penalty of running (the interpreted) Ruby and not a fully compiled language.

## Conclusion
I had learnt a lot from this exercise. It was quite challenging to fully "decrypt" the internals of the algorithm, which although it was simple enough, it still had minute nuances which had a surprisingly substantial impact on the result.
It was fun to write in Ruby and I gained experience there, but I'm still vegy-green in this language. Sadly, this fun-time was shattered by the poor performance of the langauge (interpreted...) which raised to my head the famous phrase about "using the right tool for the right task".

##Appendix - Output files
- output_train.txt - running the train sample as a learning set and as a test set, with N records per tree and 200 trees in the forest.
- output_test.txt - running the train sample as a learning set and the test set as a test set, with N records per tree and 200 trees in the forest.
- 2d-graph.xlsx - 2D graph displaying the different classes in gray and the errors of the prediction in yellow
- forestError.xlsx - 4 graphs displaying the progressive error of the forest while growing the forest, generally showing that the forest improves as it grow to a certain extent and then it starts to slightly deteriorate. In my case this graphs are not very distinctive as they were generated during with only 70 records per tree.

