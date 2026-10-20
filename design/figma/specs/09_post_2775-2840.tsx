// Figma get_design_context output (verbatim) — node 2775:2840 "home-feed-2" (outfit post screen)
// File: Z6aHsxkD41lT8lZ8JiBsQv, fetched 2026-10-20. Asset URLs expire 2026-10-27; assets live in design/figma/raw/post
// (names mapped in the comments below). Screenshot: design/figma/screens/09_post_2775-2840.png (311×1024).
// Styles in design: "Stylper soft".
//   43be2.png avatar_rectangle.png        3408f.png avatar_rectangle_overlay.png  0c66d.png image_frame_fill.png
//   14e83.png post_photo_image18.png      66f5d/ad7e5/8b58c.png product_container_{1,2,3}.png
//   1ffdb.png product_cardigan.png        fee4e.png product_trousers.png          4ad76.png product_shirt.png
//   463be.png trending_card.png           b65fa.png trending_image43.png          e5102.png trending_image17.png
//   9bc31.svg more_frame.svg              8a8f3.svg tag_dot.svg                   9ca0c.svg chevron_left.svg
//   a25e4.svg heart.svg                   c3498.svg message_circle.svg            8e7b1.svg send.svg
//   5f758.svg bookmark.svg                (status bar icons not downloaded)
const assetPathPrefix = "https://www.figma.com/api/mcp/asset/d7f7de5b-59e8-455c-8368-8310b99d7e26";
const imgRectangle = `${assetPathPrefix}/43be2.png`;
const imgRectangle1 = `${assetPathPrefix}/3408f.png`;
const imgImageFrame = `${assetPathPrefix}/0c66d.png`;
const imgImage18 = `${assetPathPrefix}/14e83.png`;
const imgProductImageContainer = `${assetPathPrefix}/66f5d.png`;
const imgRectangle2 = `${assetPathPrefix}/1ffdb.png`;
const imgProductImageContainer1 = `${assetPathPrefix}/ad7e5.png`;
const imgRectangle3 = `${assetPathPrefix}/fee4e.png`;
const imgProductImageContainer2 = `${assetPathPrefix}/8b58c.png`;
const imgRectangle4 = `${assetPathPrefix}/4ad76.png`;
const imgTrendingCard = `${assetPathPrefix}/463be.png`;
const imgImage43 = `${assetPathPrefix}/b65fa.png`;
const imgImage17 = `${assetPathPrefix}/e5102.png`;
const imgIosSignal = `${assetPathPrefix}/cc828.svg`;
const imgIosWifiSignal = `${assetPathPrefix}/9dfcf.svg`;
const imgIosBatteryFull = `${assetPathPrefix}/7b0ac.svg`;
const imgFrame = `${assetPathPrefix}/9bc31.svg`;
const imgCardiganDot = `${assetPathPrefix}/8a8f3.svg`;
const imgChevronLeft = `${assetPathPrefix}/9ca0c.svg`;
const imgHeart = `${assetPathPrefix}/a25e4.svg`;
const imgMessageCircle = `${assetPathPrefix}/c3498.svg`;
const imgSend = `${assetPathPrefix}/8e7b1.svg`;
const imgBookmark = `${assetPathPrefix}/5f758.svg`;

export default function HomeFeed2() {
  return (
    <div className="bg-[#fafaf7] overflow-clip relative rounded-[40px] size-full" data-node-id="2775:2840" data-name="home-feed-2">
      <div className="absolute content-stretch flex h-[44px] items-center justify-between left-0 px-[20px] top-0 w-[390px]" data-node-id="2775:2841" data-name="StatusBar">
        <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[14px] whitespace-nowrap" data-node-id="2775:2842">
          9:41
        </p>
        <div className="content-stretch flex gap-[6px] items-center relative shrink-0" data-node-id="2775:2843" data-name="Icons">
          <div className="h-[10px] relative shrink-0 w-[18px]" data-node-id="2775:2844" data-name="ios-signal">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIosSignal} />
          </div>
          <div className="h-[12px] relative shrink-0 w-[16px]" data-node-id="2775:2846" data-name="ios-wifi-signal">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIosWifiSignal} />
          </div>
          <div className="h-[12px] relative shrink-0 w-[24px]" data-node-id="2775:2848" data-name="ios-battery-full">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIosBatteryFull} />
          </div>
        </div>
      </div>
      <div className="absolute h-[792px] left-0 overflow-clip right-0 top-[44px]" data-node-id="2775:2850" data-name="FeedContent">
        <div className="absolute bg-[#f2f2f0] content-stretch flex flex-col items-start left-0 right-0 top-0" data-node-id="2775:2851" data-name="Card-Outfit">
          <div className="content-stretch flex items-center justify-between pb-[10px] pt-[12px] px-[16px] relative shrink-0 w-full" data-node-id="2775:2852" data-name="User-Row">
            <div className="content-stretch flex gap-[8px] items-center relative shrink-0" data-node-id="2775:2853" data-name="Frame">
              <div className="content-stretch flex flex-col items-start overflow-clip relative rounded-[15px] shrink-0 size-[30px]" data-node-id="2775:2854" data-name="Avatar">
                <div className="flex-[1_0_0] min-h-px relative w-full" data-node-id="2775:2855" data-name="Rectangle">
                  <div aria-hidden className="absolute inset-0 pointer-events-none">
                    <img alt="" className="absolute max-w-none object-cover size-full" src={imgRectangle} />
                    <img alt="" className="absolute max-w-none object-cover size-full" src={imgRectangle1} />
                  </div>
                </div>
              </div>
              <p className="[word-break:break-word] font-['Inter:Medium'] font-medium leading-[normal] not-italic relative shrink-0 text-[#332e3d] text-[13px] whitespace-nowrap" data-node-id="2775:2856">
                John. B
              </p>
            </div>
            <div className="h-[3px] relative shrink-0 w-[15px]" data-node-id="2775:2857" data-name="Frame">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgFrame} />
            </div>
          </div>
          <div className="h-[516px] overflow-clip relative shrink-0 w-full" data-node-id="2775:2861" data-name="Image-Frame">
            <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none size-full" src={imgImageFrame} />
            <div className="absolute h-[516px] left-0 top-0 w-[390px]" data-node-id="2775:2863" data-name="image 18">
              <div className="absolute inset-0 overflow-hidden pointer-events-none">
                <img alt="" className="absolute h-[118.71%] left-[-17.18%] max-w-none top-[-8.31%] w-[134.36%]" src={imgImage18} />
              </div>
            </div>
            <div className="absolute backdrop-blur-[5px] bg-[rgba(26,26,26,0.65)] border border-[rgba(26,26,26,0.4)] border-solid content-stretch flex items-center left-[200px] px-[10px] py-[6px] rounded-[999px] top-[200px]" data-node-id="2775:2864" data-name="cardigan-tag">
              <p className="[word-break:break-word] font-['Inter:Medium'] font-medium leading-[normal] not-italic relative shrink-0 text-[#fafaf7] text-[11px] whitespace-nowrap" data-node-id="2775:2865">
                Uniqlo · Cardigan
              </p>
            </div>
            <div className="absolute left-[188px] size-[6px] top-[188px]" data-node-id="2775:2866" data-name="cardigan-dot">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgCardiganDot} />
            </div>
            <div className="absolute backdrop-blur-[5px] bg-[rgba(26,26,26,0.65)] border border-[rgba(26,26,26,0.4)] border-solid content-stretch flex items-center left-[120px] px-[10px] py-[6px] rounded-[999px] top-[300px]" data-node-id="2775:2867" data-name="shirt-tag">
              <p className="[word-break:break-word] font-['Inter:Medium'] font-medium leading-[normal] not-italic relative shrink-0 text-[#fafaf7] text-[11px] whitespace-nowrap" data-node-id="2775:2868">
                COS · Shirt
              </p>
            </div>
            <div className="absolute left-[108px] size-[6px] top-[288px]" data-node-id="2775:2869" data-name="shirt-dot">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgCardiganDot} />
            </div>
            <div className="absolute backdrop-blur-[5px] bg-[rgba(26,26,26,0.65)] border border-[rgba(26,26,26,0.4)] border-solid content-stretch flex items-center left-[200px] px-[10px] py-[6px] rounded-[999px] top-[420px]" data-node-id="2775:2870" data-name="trousers-tag">
              <p className="[word-break:break-word] font-['Inter:Medium'] font-medium leading-[normal] not-italic relative shrink-0 text-[#fafaf7] text-[11px] whitespace-nowrap" data-node-id="2775:2871">
                Zara · Trousers
              </p>
            </div>
            <div className="absolute left-[188px] size-[6px] top-[408px]" data-node-id="2775:2872" data-name="trousers-dot">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgCardiganDot} />
            </div>
            <div className="absolute bg-gradient-to-b from-[rgba(14,8,22,0)] h-[119px] left-0 to-[rgba(14,8,22,0.8)] top-[397px] w-[390px]" data-node-id="2775:2873" data-name="Gradient-Fade" />
            <div className="absolute left-[19px] size-[30px] top-[12px]" data-node-id="2775:2874">
              <div className="absolute bg-[rgba(250,250,247,0.8)] left-0 rounded-[4px] size-[30px] top-0" data-node-id="2775:2875" />
              <div className="absolute left-[6px] size-[18px] top-[5px]" data-node-id="2775:2876" data-name="chevron-left">
                <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgChevronLeft} />
              </div>
            </div>
          </div>
          <div className="content-stretch flex items-center justify-between pb-[16px] pt-[14px] px-[16px] relative shrink-0 w-full" data-node-id="2775:2878" data-name="Social-Actions">
            <div className="content-stretch flex gap-[20px] items-center relative shrink-0" data-node-id="2775:2879" data-name="Frame">
              <div className="content-stretch flex gap-[6px] items-center relative shrink-0" data-node-id="2775:2880" data-name="Frame">
                <div className="content-stretch flex flex-col items-center justify-center relative shrink-0 size-[18px]" data-node-id="2775:2881" data-name="icon-wrapper">
                  <div className="relative shrink-0 size-[18px]" data-node-id="2775:2882" data-name="heart">
                    <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgHeart} />
                  </div>
                </div>
                <p className="[word-break:break-word] font-['Inter:Medium'] font-medium leading-[normal] not-italic relative shrink-0 text-[#736b85] text-[13px] whitespace-nowrap" data-node-id="2775:2884">
                  412
                </p>
              </div>
              <div className="content-stretch flex gap-[6px] items-center relative shrink-0" data-node-id="2775:2885" data-name="Frame">
                <div className="content-stretch flex flex-col items-center justify-center relative shrink-0 size-[18px]" data-node-id="2775:2886" data-name="icon-wrapper">
                  <div className="relative shrink-0 size-[18px]" data-node-id="2775:2887" data-name="message-circle">
                    <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgMessageCircle} />
                  </div>
                </div>
                <p className="[word-break:break-word] font-['Inter:Medium'] font-medium leading-[normal] not-italic relative shrink-0 text-[#736b85] text-[13px] whitespace-nowrap" data-node-id="2775:2889">
                  28
                </p>
              </div>
              <div className="content-stretch flex flex-col items-center justify-center relative shrink-0 size-[18px]" data-node-id="2775:2890" data-name="icon-wrapper">
                <div className="relative shrink-0 size-[18px]" data-node-id="2775:2891" data-name="send">
                  <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgSend} />
                </div>
              </div>
            </div>
            <div className="content-stretch flex flex-col items-center justify-center relative shrink-0 size-[18px]" data-node-id="2775:2893" data-name="icon-wrapper">
              <div className="relative shrink-0 size-[18px]" data-node-id="2775:2894" data-name="bookmark">
                <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgBookmark} />
              </div>
            </div>
          </div>
          <div className="bg-[#ebebe8] h-px relative shrink-0 w-full" data-node-id="2775:2896" data-name="Divider" />
        </div>
        <div className="absolute h-[236px] left-[8px] top-[613px] w-[373px]" data-node-id="2775:2897" data-name="Outfit-Details-Section">
          <p className="[word-break:break-word] absolute font-['Inter:Semi_Bold'] font-semibold leading-[normal] left-[16px] not-italic text-[#736b85] text-[11px] top-[16px] tracking-[0.5px] uppercase whitespace-nowrap" data-node-id="2775:2898">
            Outfit Details
          </p>
          <div className="absolute content-stretch flex gap-[18px] h-[187px] items-start left-[6px] right-0 top-[41px]" data-node-id="2775:2899" data-name="Product-Grid">
            <div className="bg-[#f2f2f0] content-stretch flex flex-col h-[129px] items-start overflow-clip relative rounded-[6px] shrink-0 w-[110px]" data-node-id="2775:2900" data-name="Frame">
              <div className="h-[90px] overflow-clip relative shrink-0 w-full" data-node-id="2775:2901" data-name="Product-Image-Container">
                <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none size-full" src={imgProductImageContainer} />
                <div className="absolute h-[90px] left-0 top-0 w-[110px]" data-node-id="2775:2903" data-name="Rectangle">
                  <div aria-hidden className="absolute inset-0 pointer-events-none">
                    <div className="absolute bg-[#ebeae5] inset-0" />
                    <div className="absolute inset-0 overflow-hidden">
                      <img alt="" className="absolute h-[147.61%] left-[7.49%] max-w-none top-[-23.71%] w-[82.77%]" src={imgRectangle2} />
                    </div>
                  </div>
                </div>
              </div>
              <div className="[word-break:break-word] content-stretch flex flex-col gap-[4px] items-start leading-[normal] not-italic px-[8px] py-[6px] relative shrink-0 w-full" data-node-id="2775:2904" data-name="Frame">
                <p className="font-['Inter:Semi_Bold'] font-semibold overflow-hidden relative shrink-0 text-[#332e3d] text-[10px] text-ellipsis w-full whitespace-nowrap" data-node-id="2775:2905">
                  Cardigan
                </p>
                <p className="font-['Inter:Regular'] font-normal overflow-hidden relative shrink-0 text-[#736b85] text-[9px] text-ellipsis w-full whitespace-pre" data-node-id="2775:2906">{`Uniqlo                   40$`}</p>
              </div>
            </div>
            <div className="bg-[#f2f2f0] content-stretch flex flex-col items-start overflow-clip relative rounded-[6px] shrink-0 w-[110px]" data-node-id="2775:2907" data-name="Frame">
              <div className="h-[90px] overflow-clip relative shrink-0 w-full" data-node-id="2775:2908" data-name="Product-Image-Container">
                <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none size-full" src={imgProductImageContainer1} />
                <div className="absolute h-[90px] left-0 top-0 w-[110px]" data-node-id="2775:2910" data-name="Rectangle">
                  <div aria-hidden className="absolute inset-0 pointer-events-none">
                    <div className="absolute bg-[#eeeff3] inset-0" />
                    <div className="absolute inset-0 overflow-hidden">
                      <img alt="" className="absolute h-[100.13%] left-[11.66%] max-w-none top-[0.47%] w-[74.49%]" src={imgRectangle3} />
                    </div>
                  </div>
                </div>
              </div>
              <div className="[word-break:break-word] content-stretch flex flex-col gap-[4px] items-start leading-[normal] not-italic px-[8px] py-[6px] relative shrink-0 w-full" data-node-id="2775:2911" data-name="Frame">
                <p className="font-['Inter:Semi_Bold'] font-semibold overflow-hidden relative shrink-0 text-[#332e3d] text-[10px] text-ellipsis w-full whitespace-nowrap" data-node-id="2775:2912">
                  Trousers
                </p>
                <p className="font-['Inter:Regular'] font-normal overflow-hidden relative shrink-0 text-[#736b85] text-[9px] text-ellipsis w-full whitespace-pre" data-node-id="2775:2913">{`Massimo Dutti      55$`}</p>
              </div>
            </div>
            <div className="bg-[#f2f2f0] content-stretch flex flex-col items-start overflow-clip relative rounded-[6px] shrink-0 w-[110px]" data-node-id="2775:2914" data-name="Frame">
              <div className="h-[90px] overflow-clip relative shrink-0 w-full" data-node-id="2775:2915" data-name="Product-Image-Container">
                <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none size-full" src={imgProductImageContainer2} />
                <div className="absolute h-[90px] left-0 top-0 w-[110px]" data-node-id="2775:2917" data-name="Rectangle">
                  <div aria-hidden className="absolute inset-0 pointer-events-none">
                    <div className="absolute bg-[#f1f1f1] inset-0" />
                    <div className="absolute inset-0 overflow-hidden">
                      <img alt="" className="absolute h-[99.08%] left-[13.21%] max-w-none top-[0.92%] w-[73.7%]" src={imgRectangle4} />
                    </div>
                  </div>
                </div>
              </div>
              <div className="[word-break:break-word] content-stretch flex flex-col gap-[4px] items-start leading-[normal] not-italic px-[8px] py-[6px] relative shrink-0 w-full" data-node-id="2775:2918" data-name="Frame">
                <p className="font-['Inter:Semi_Bold'] font-semibold overflow-hidden relative shrink-0 text-[#332e3d] text-[10px] text-ellipsis w-full whitespace-nowrap" data-node-id="2775:2919">
                  Shirt
                </p>
                <p className="font-['Inter:Regular'] font-normal overflow-hidden relative shrink-0 text-[#736b85] text-[9px] text-ellipsis w-full whitespace-pre" data-node-id="2775:2920">{`COS                      35$`}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      <p className="[word-break:break-word] absolute font-['Inter:Semi_Bold'] font-semibold leading-[normal] left-[24px] not-italic text-[#736b85] text-[11px] top-[872px] tracking-[0.5px] uppercase whitespace-nowrap" data-node-id="2775:2921">
        Similar
      </p>
      <div className="absolute bg-gradient-to-b border-[0.4px] border-[rgba(26,26,26,0.15)] border-solid content-stretch flex from-[var(--stylper-1,#c11e38)] items-start left-[14px] px-[6.792px] py-[4.075px] rounded-[7px] to-[#ff627b] top-[833px] w-[34px]" data-node-id="2775:2922" data-name="Frame">
        <p className="[word-break:break-word] font-['Poppins:Medium'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[7.472px] whitespace-nowrap" data-node-id="2775:2923">
          Shop
        </p>
      </div>
      <div className="absolute bg-gradient-to-b border-[0.4px] border-[rgba(26,26,26,0.15)] border-solid content-stretch flex from-[var(--stylper-1,#c11e38)] items-start left-[142px] px-[6.792px] py-[4.075px] rounded-[7px] to-[#ff627b] top-[833px]" data-node-id="2775:2924" data-name="Frame">
        <p className="[word-break:break-word] font-['Poppins:Medium'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[7.472px] whitespace-nowrap" data-node-id="2775:2925">
          Shop
        </p>
      </div>
      <div className="absolute bg-gradient-to-b border-[0.4px] border-[rgba(26,26,26,0.15)] border-solid content-stretch flex from-[var(--stylper-1,#c11e38)] items-start left-[270px] px-[6.792px] py-[4.075px] rounded-[7px] to-[#ff627b] top-[833px]" data-node-id="2775:2926" data-name="Frame">
        <p className="[word-break:break-word] font-['Poppins:Medium'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[7.472px] whitespace-nowrap" data-node-id="2775:2927">
          Shop
        </p>
      </div>
      <div className="absolute bg-[#f2f2f0] border-[0.4px] border-[rgba(26,26,26,0.15)] border-solid content-stretch flex items-start left-[50px] px-[6.571px] py-[3.942px] rounded-[7px] top-[833px] w-[74px]" data-node-id="2775:2928" data-name="Frame">
        <p className="[word-break:break-word] font-['Poppins:Medium'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[7.228px] whitespace-nowrap" data-node-id="2775:2929">
          Add to wardrobe
        </p>
      </div>
      <div className="absolute bg-[#f2f2f0] border-[0.4px] border-[rgba(26,26,26,0.15)] border-solid content-stretch flex items-start left-[178px] px-[6.571px] py-[3.942px] rounded-[7px] top-[833px] w-[74px]" data-node-id="2775:2930" data-name="Frame">
        <p className="[word-break:break-word] font-['Poppins:Medium'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[7.228px] whitespace-nowrap" data-node-id="2775:2931">
          Add to wardrobe
        </p>
      </div>
      <div className="absolute bg-[#f2f2f0] border-[0.4px] border-[rgba(26,26,26,0.15)] border-solid content-stretch flex items-start left-[306px] px-[6.571px] py-[3.942px] rounded-[7px] top-[833px] w-[74px]" data-node-id="2775:2932" data-name="Frame">
        <p className="[word-break:break-word] font-['Poppins:Medium'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[7.228px] whitespace-nowrap" data-node-id="2775:2933">
          Add to wardrobe
        </p>
      </div>
      <div className="absolute h-[516px] left-[14px] right-[10px] top-[872px]" data-node-id="2775:2934" data-name="Trending Section">
        <div className="absolute content-stretch flex gap-[12px] h-[264px] items-start left-0 right-0 top-[31px]" data-node-id="2775:2935" data-name="Trending Row">
          <div className="content-stretch flex flex-col h-[264px] items-start overflow-clip relative rounded-[20px] shrink-0 w-[177px]" data-node-id="2775:2936" data-name="Trending Card">
            <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none rounded-[20px] size-full" src={imgImage18} />
            <div className="[word-break:break-word] absolute bottom-[12px] content-stretch flex flex-col gap-[2px] items-start leading-[normal] left-[12px] not-italic text-shadow-[0px_1px_0.8px_rgba(0,0,0,0.37)] whitespace-nowrap" data-node-id="2775:2937" data-name="Frame">
              <p className="font-['Poppins:SemiBold'] relative shrink-0 text-[12px] text-white" data-node-id="2775:2938">
                Utility chic
              </p>
              <p className="font-['Poppins:Regular'] relative shrink-0 text-[11px] text-[rgba(255,255,255,0.8)]" data-node-id="2775:2939">
                @leo
              </p>
            </div>
          </div>
          <div className="content-stretch flex flex-col h-[228px] items-start overflow-clip relative rounded-[20px] shrink-0 w-[177px]" data-node-id="2775:2940" data-name="Trending Card">
            <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none rounded-[20px] size-full" src={imgTrendingCard} />
            <div className="[word-break:break-word] absolute bottom-[12px] content-stretch flex flex-col gap-[2px] items-start leading-[normal] left-[12px] not-italic text-shadow-[0px_1px_0.8px_rgba(0,0,0,0.37)] whitespace-nowrap" data-node-id="2775:2941" data-name="Frame">
              <p className="font-['Poppins:SemiBold'] relative shrink-0 text-[12px] text-white" data-node-id="2775:2942">
                Soft neutrals
              </p>
              <p className="font-['Poppins:Regular'] relative shrink-0 text-[11px] text-[rgba(255,255,255,0.8)]" data-node-id="2775:2943">
                @bob
              </p>
            </div>
          </div>
        </div>
        <div className="absolute bg-[#807a87] h-[238px] left-[189px] overflow-clip rounded-[11.8px] top-[278px] w-[177px]" data-node-id="2775:2944">
          <div className="absolute h-[240.384px] left-[-1.97px] top-[-4.92px] w-[180.349px]" data-node-id="2775:2945" data-name="image 34">
            <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none size-full" src={imgTrendingCard} />
          </div>
          <div className="absolute h-[279.834px] left-[-12.63px] top-[-34.73px] w-[190.701px]" data-node-id="2775:2946" data-name="image 43">
            <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none size-full" src={imgImage43} />
          </div>
          <p className="[word-break:break-word] absolute font-['Poppins:SemiBold'] leading-[normal] left-[12px] not-italic text-[#1a1a1a] text-[12px] text-shadow-[0px_1px_0.8px_rgba(0,0,0,0.37)] top-[189px] whitespace-nowrap" data-node-id="2775:2947">
            No words
          </p>
          <p className="[word-break:break-word] absolute font-['Poppins:Regular'] leading-[normal] left-[12px] not-italic text-[11px] text-[rgba(26,26,26,0.8)] text-shadow-[0px_1px_0.8px_rgba(0,0,0,0.37)] top-[209px] whitespace-nowrap" data-node-id="2775:2948">
            @zokir
          </p>
        </div>
        <div className="absolute bg-[#807a87] h-[197px] left-0 overflow-clip rounded-[12px] top-[319px] w-[180px]" data-node-id="2775:2949">
          <div className="absolute h-[284px] left-[-19px] top-0 w-[217px]" data-node-id="2775:2950" data-name="image 17">
            <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none size-full" src={imgImage17} />
          </div>
          <p className="[word-break:break-word] absolute font-['Poppins:SemiBold'] leading-[normal] left-[12px] not-italic text-[#1a1a1a] text-[12px] text-shadow-[0px_1px_0.8px_rgba(0,0,0,0.37)] top-[148px] whitespace-nowrap" data-node-id="2775:2951">
            I like my Outfit
          </p>
          <p className="[word-break:break-word] absolute font-['Poppins:Regular'] leading-[normal] left-[12px] not-italic text-[11px] text-[rgba(26,26,26,0.8)] text-shadow-[0px_1px_0.8px_rgba(0,0,0,0.37)] top-[168px] whitespace-nowrap" data-node-id="2775:2952">
            @fozil
          </p>
        </div>
      </div>
    </div>
  );
}
