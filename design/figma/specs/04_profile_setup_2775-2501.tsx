// Figma get_design_context output (verbatim) — node 2775:2501 "profile-setup"
// File: Z6aHsxkD41lT8lZ8JiBsQv, fetched 2026-10-07. Asset URLs are expired; assets live in design/figma/raw/profile.
// Note: GenderOptions are 169 + 12 + 169 = 350px wide inside a 342px column (design overflow).
const assetPathPrefix = "https://www.figma.com/api/mcp/asset/8de529a3-2edb-4403-a18e-2290c6af609c";
const imgIosSignal = `${assetPathPrefix}/5a313.svg`;
const imgIosWifiSignal = `${assetPathPrefix}/15db7.svg`;
const imgIosBatteryFull = `${assetPathPrefix}/6fc44.svg`;
const imgAtSign = `${assetPathPrefix}/3dcbe.svg`;
const imgCalendar = `${assetPathPrefix}/1c329.svg`;
const imgRuler = `${assetPathPrefix}/8c826.svg`;
const imgScale = `${assetPathPrefix}/6c439.svg`;

export default function ProfileSetup() {
  return (
    <div className="bg-[#fafaf7] overflow-clip relative rounded-[40px] size-full" data-node-id="2775:2501" data-name="profile-setup">
      <div className="absolute content-stretch flex flex-col h-[775px] items-start left-0 right-0 top-0" data-node-id="2775:2502" data-name="TopContent">
        <div className="content-stretch flex h-[44px] items-center justify-between px-[20px] relative shrink-0 w-full" data-node-id="2775:2503" data-name="StatusBar">
          <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[14px] whitespace-nowrap" data-node-id="2775:2504">
            9:41
          </p>
          <div className="content-stretch flex gap-[6px] items-center relative shrink-0" data-node-id="2775:2505" data-name="Icons">
            <div className="h-[10px] overflow-clip relative shrink-0 w-[18px]" data-node-id="2775:2506" data-name="ios-signal">
              <div className="absolute inset-[21.93%_4%_16.93%_0]" data-node-id="2775:2507" data-name="ios-signal">
                <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIosSignal} />
              </div>
            </div>
            <div className="h-[12px] overflow-clip relative shrink-0 w-[16px]" data-node-id="2775:2509" data-name="ios-wifi-signal">
              <div className="absolute inset-[16.68%_9.29%_21.68%_5%]" data-node-id="2775:2510" data-name="ios-wifi-signal">
                <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIosWifiSignal} />
              </div>
            </div>
            <div className="h-[12px] overflow-clip relative shrink-0 w-[24px]" data-node-id="2775:2512" data-name="ios-battery-full">
              <div className="absolute inset-[20%_2.4%_15%_0]" data-node-id="2775:2513" data-name="ios-battery-full">
                <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIosBatteryFull} />
              </div>
            </div>
          </div>
        </div>
        <div className="h-[672px] relative shrink-0 w-full" data-node-id="2775:2515" data-name="Content">
          <div className="[word-break:break-word] absolute h-[84px] left-[24px] not-italic right-[24px] top-[61px]" data-node-id="2775:2516" data-name="Header">
            <p className="absolute font-['Inter:Extra_Bold'] font-extrabold leading-[normal] left-0 right-0 text-[#1a1a1a] text-[28px] top-0 tracking-[-0.5px]" data-node-id="2775:2517">
              Set Up Your Profile
            </p>
            <p className="absolute font-['Inter:Regular'] font-normal leading-[1.4] left-0 right-0 text-[#807a87] text-[15px] top-[42px]" data-node-id="2775:2518">
              Help us personalize your style recommendations and fits
            </p>
          </div>
          <div className="absolute h-[423px] left-[24px] right-[24px] top-[169px]" data-node-id="2775:2519" data-name="Form">
            <div className="absolute content-stretch flex flex-col gap-[8px] items-start left-0 right-0 top-0" data-node-id="2775:2520" data-name="Field-Username">
              <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[12px] tracking-[0.5px] uppercase w-full" data-node-id="2775:2521">
                Username
              </p>
              <div className="bg-[rgba(26,26,26,0.05)] border border-[rgba(26,26,26,0.1)] border-solid content-stretch flex gap-[12px] h-[50px] items-center px-[16px] relative rounded-[12px] shrink-0 w-full" data-node-id="2775:2522" data-name="InputContainer">
                <div className="overflow-clip relative shrink-0 size-[18px]" data-node-id="2775:2523" data-name="IconFrame">
                  <div className="absolute left-0 size-[18px] top-0" data-node-id="2775:2524" data-name="at-sign">
                    <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgAtSign} />
                  </div>
                </div>
                <p className="[word-break:break-word] flex-[1_0_0] font-['Inter:Regular'] font-normal leading-[normal] min-w-px not-italic relative text-[#807a87] text-[15px]" data-node-id="2775:2526">
                  @katty_miller
                </p>
              </div>
            </div>
            <div className="absolute content-stretch flex flex-col gap-[8px] items-start left-0 right-0 top-[89px]" data-node-id="2775:2527" data-name="Field-Gender">
              <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[12px] tracking-[0.5px] uppercase w-full" data-node-id="2775:2528">
                Gender
              </p>
              <div className="content-stretch flex gap-[12px] items-start relative shrink-0 w-full" data-node-id="2775:2529" data-name="GenderOptions">
                <div className="bg-gradient-to-b content-stretch flex from-[var(--stylper-1,#c11e38)] h-[44px] items-center justify-center relative rounded-[22px] shrink-0 to-[#ff627b] w-[169px]" data-node-id="2775:2530" data-name="MaleOption">
                  <p className="[word-break:break-word] font-['Inter:Bold'] font-bold leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[14px] whitespace-nowrap" data-node-id="2775:2531">
                    Male
                  </p>
                </div>
                <div className="bg-[rgba(26,26,26,0.05)] border border-[rgba(26,26,26,0.1)] border-solid content-stretch flex h-[44px] items-center justify-center relative rounded-[22px] shrink-0 w-[169px]" data-node-id="2775:2532" data-name="FemaleOption">
                  <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[14px] whitespace-nowrap" data-node-id="2775:2533">
                    Female
                  </p>
                </div>
              </div>
            </div>
            <div className="absolute content-stretch flex flex-col gap-[8px] items-start left-0 right-0 top-[172px]" data-node-id="2775:2534" data-name="Field-Age">
              <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[12px] tracking-[0.5px] uppercase w-full" data-node-id="2775:2535">
                Age
              </p>
              <div className="bg-[rgba(26,26,26,0.05)] border border-[rgba(26,26,26,0.1)] border-solid content-stretch flex gap-[12px] h-[50px] items-center px-[16px] relative rounded-[12px] shrink-0 w-full" data-node-id="2775:2536" data-name="InputContainer">
                <div className="overflow-clip relative shrink-0 size-[18px]" data-node-id="2775:2537" data-name="IconFrame">
                  <div className="absolute left-0 size-[18px] top-0" data-node-id="2775:2538" data-name="calendar">
                    <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgCalendar} />
                  </div>
                </div>
                <p className="[word-break:break-word] flex-[1_0_0] font-['Inter:Regular'] font-normal leading-[normal] min-w-px not-italic relative text-[#807a87] text-[15px]" data-node-id="2775:2540">
                  e.g. 24
                </p>
              </div>
            </div>
            <div className="absolute content-stretch flex flex-col gap-[8px] items-start left-0 right-0 top-[261px]" data-node-id="2775:2541" data-name="Field-Height">
              <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[12px] tracking-[0.5px] uppercase w-full" data-node-id="2775:2542">
                Height
              </p>
              <div className="bg-[rgba(26,26,26,0.05)] border border-[rgba(26,26,26,0.1)] border-solid content-stretch flex gap-[12px] h-[50px] items-center px-[16px] relative rounded-[12px] shrink-0 w-full" data-node-id="2775:2543" data-name="InputContainer">
                <div className="overflow-clip relative shrink-0 size-[18px]" data-node-id="2775:2544" data-name="IconFrame">
                  <div className="absolute left-0 size-[18px] top-0" data-node-id="2775:2545" data-name="ruler">
                    <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgRuler} />
                  </div>
                </div>
                <p className="[word-break:break-word] flex-[1_0_0] font-['Inter:Regular'] font-normal leading-[normal] min-w-px not-italic relative text-[#807a87] text-[15px]" data-node-id="2775:2547">
                  Height in cm
                </p>
              </div>
            </div>
            <div className="absolute content-stretch flex flex-col gap-[8px] items-start left-0 right-0 top-[350px]" data-node-id="2775:2548" data-name="Field-Weight">
              <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[12px] tracking-[0.5px] uppercase w-full" data-node-id="2775:2549">
                Weight
              </p>
              <div className="bg-[rgba(26,26,26,0.05)] border border-[rgba(26,26,26,0.1)] border-solid content-stretch flex gap-[12px] h-[50px] items-center px-[16px] relative rounded-[12px] shrink-0 w-full" data-node-id="2775:2550" data-name="InputContainer">
                <div className="overflow-clip relative shrink-0 size-[18px]" data-node-id="2775:2551" data-name="IconFrame">
                  <div className="absolute left-0 size-[18px] top-0" data-node-id="2775:2552" data-name="scale">
                    <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgScale} />
                  </div>
                </div>
                <p className="[word-break:break-word] flex-[1_0_0] font-['Inter:Regular'] font-normal leading-[normal] min-w-px not-italic relative text-[#807a87] text-[15px]" data-node-id="2775:2554">
                  Weight in kg
                </p>
              </div>
            </div>
          </div>
          <div className="absolute h-[85px] left-[24px] right-[24px] top-[616px]" data-node-id="2775:2555" data-name="ActionContainer">
            <div className="absolute bg-gradient-to-b content-stretch flex from-[var(--stylper-1,#c11e38)] h-[52px] items-center justify-center left-0 right-0 rounded-[14px] to-[#ff627b] top-0" data-node-id="2775:2556" data-name="PrimarySubmit">
              <p className="[word-break:break-word] font-['Inter:Bold'] font-bold leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[16px] whitespace-nowrap" data-node-id="2775:2557">
                Continue
              </p>
            </div>
            <div className="absolute content-stretch flex h-[17px] items-start justify-center left-0 right-0 top-[68px]" data-node-id="2775:2558" data-name="SkipContainer">
              <p className="[word-break:break-word] font-['Inter:Medium'] font-medium leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[14px] whitespace-nowrap" data-node-id="2775:2559">
                Skip for now
              </p>
            </div>
          </div>
        </div>
      </div>
      <div className="absolute content-stretch flex flex-col items-start left-0 right-0 top-[810px]" data-node-id="2775:2560" data-name="BottomContent">
        <div className="content-stretch flex flex-col h-[34px] items-center justify-end pb-[8px] relative shrink-0 w-full" data-node-id="2775:2561" data-name="HomeIndicatorContainer">
          <div className="bg-[#1a1a1a] h-[5px] opacity-40 relative rounded-[100px] shrink-0 w-[140px]" data-node-id="2775:2562" data-name="HomeIndicator" />
        </div>
      </div>
    </div>
  );
}
