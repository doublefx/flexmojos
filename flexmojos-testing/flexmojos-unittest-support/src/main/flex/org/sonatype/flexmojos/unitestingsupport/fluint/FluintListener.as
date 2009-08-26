package org.sonatype.flexmojos.unitestingsupport.fluint
{
	import flash.events.Event;


	import net.digitalprimates.fluint.monitor.TestCaseResult;
	import net.digitalprimates.fluint.monitor.TestMethodResult;
	import net.digitalprimates.fluint.monitor.TestMonitor;
	import net.digitalprimates.fluint.monitor.TestSuiteResult;
	import net.digitalprimates.fluint.tests.TestCase;
	import net.digitalprimates.fluint.tests.TestSuite;
	import net.digitalprimates.fluint.ui.TestEnvironment;
	import net.digitalprimates.fluint.ui.TestRunner;


	import org.sonatype.flexmojos.test.report.ErrorReport;
	import org.sonatype.flexmojos.unitestingsupport.SocketReporter;
	import org.sonatype.flexmojos.unitestingsupport.util.ClassnameUtil;

	public class FluintListener
	{

		private var socketReporter:SocketReporter=SocketReporter.getInstance();
		private var _testMonitor:TestMonitor=new TestMonitor();
		private var _testSuite:TestSuite=new TestSuite();


		public function FluintListener(tests:Array)
		{
			for each (var test:Class in tests)
			{
				var testCase:*=new test();
				if (testCase is TestCase)
				{
					_testSuite.addTestCase(testCase);
				}
			}
		}

		public static function run(tests:Array):int
		{
			var listener:FluintListener=new FluintListener(tests);
			return listener.runTests();
		}

		public function runTests():int
		{
			var testRunner:TestRunner=new TestRunner(_testMonitor);
			testRunner.testEnvironment=new TestEnvironment();
			testRunner.startTests(_testSuite);
			testRunner.addEventListener(TestRunner.TESTS_COMPLETE, handleTestsComplete);
			return testRunner.getTestCount();
		}

		private function handleTestsComplete(event:Event):void
		{
			var suiteResult:TestSuiteResult=_testMonitor.getTestSuiteResult(_testSuite);
			var testResults:Array=suiteResult.children.toArray();
			testResults.forEach(reportTestCaseResult);
		}

		private function reportTestCaseResult(element:*, index:int, arr:Array):void
		{
			var testCaseResult:TestCaseResult=TestCaseResult(element);
			var testMethodResults:Array=testCaseResult.children.toArray();
			for each (var testMethodResult:TestMethodResult in testMethodResults)
			{
				reportTestMethodResult(testCaseResult, testMethodResult);
			}
		}

		private function reportTestMethodResult(testCaseResult:TestCaseResult, testMethodResult:TestMethodResult):void
		{
			startTest(testCaseResult, testMethodResult);

			if (testMethodResult.errored)
			{
				addError(testCaseResult, testMethodResult);
			}

			if (testMethodResult.failed)
			{
				addFailure(testCaseResult, testMethodResult);
			}
			endTest(testCaseResult, testMethodResult);
		}


		private function startTest(testCaseResult:TestCaseResult, testMethodResult:TestMethodResult):void
		{
			socketReporter.addMethod(testCaseResult.qualifiedClassName, testMethodResult.displayName);
		}

		private function endTest(testCaseResult:TestCaseResult, testMethodResult:TestMethodResult):void
		{
			socketReporter.testFinished(testCaseResult.qualifiedClassName, testMethodResult.testDuration);
		}

		private function addError(testCaseResult:TestCaseResult, testMethodResult:TestMethodResult):void
		{
			var error:Error=testMethodResult.error;
			var failure:ErrorReport=new ErrorReport();
			failure.type=ClassnameUtil.getClassName(error);
			failure.message=error.message;

			if (failure.message == "Setup/Teardown Error")
			{
				//in case setup or teardown fails, the testCaseResult has the actual stackTrace
				failure.stackTrace=testCaseResult.traceInformation;
			}
			else
				failure.stackTrace=error.getStackTrace();

			socketReporter.addError(testCaseResult.qualifiedClassName, testMethodResult.displayName, failure);
		}

		private function addFailure(testCaseResult:TestCaseResult, testMethodResult:TestMethodResult):void
		{
			var error:Error=testMethodResult.error;
			var failure:ErrorReport=new ErrorReport();
			failure.type=ClassnameUtil.getClassName(error);
			failure.message=error.message;
			failure.stackTrace=error.getStackTrace();
			socketReporter.addFailure(testCaseResult.qualifiedClassName, testMethodResult.displayName, failure);
		}

	}
}